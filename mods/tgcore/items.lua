-- Item despawn timer
local ITEM_DESPAWN_TIME = 300  -- 5 minutes

-- Item drop and pickup system
local PICKUP_RADIUS = 1.5
local PLAYER_DROP_PICKUP_DELAY = 2.0  -- seconds before player-dropped items can be picked up
local LAVA_DESTROY_TIME = 1.0  -- seconds before items in lava are destroyed

local item_entity = minetest.registered_entities["__builtin:item"]
if item_entity then
    local old_on_step = item_entity.on_step
    item_entity.on_step = function(self, dtime, moveresult)
        old_on_step(self, dtime, moveresult)

        -- Stop sliding by killing horizontal velocity when on ground
        if moveresult and moveresult.touching_ground then
            local vel = self.object:get_velocity()
            if vel then
                self.object:set_velocity({
                    x = vel.x * 0.6,
                    y = vel.y,
                    z = vel.z * 0.6,
                })
            end
        end
        -- Destroy items that land in lava
        local pos = self.object:get_pos()
        if pos then
            local node = minetest.get_node(pos)
            if node.name == "tgcore:lava_source" or node.name == "tgcore:lava_flowing" then
                -- Start or increment lava timer
                self._lava_time = (self._lava_time or 0) + dtime
                if self._lava_time >= LAVA_DESTROY_TIME then
                    self.object:remove()
                    return
                end
            else
                -- Reset timer if item leaves lava
                self._lava_time = nil
            end
        end

        -- Despawn timer
        self._age = (self._age or 0) + dtime
        if self._age >= ITEM_DESPAWN_TIME then
            self.object:remove()
        end
    end

    -- disable punch-to-pickup
    local old_on_punch = item_entity.on_punch
    item_entity.on_punch = function(self, hitter)
        -- do nothing
    end
end

-- Suppress engine default of putting dug items directly in inventory
minetest.handle_node_drops = function(pos, drops, digger)
    for _, itemstring in ipairs(drops) do
        local obj = minetest.add_item(pos, itemstring)
        if obj then
            obj:set_velocity({
                x = math.random(-2, 2) * 0.5,
                y = 3,
                z = math.random(-2, 2) * 0.5,
            })
        end
    end
end

-- Tag freshly spawned item entities near pos as player-dropped
-- so the pickup system applies a delay before allowing pickup
local function tag_dropped_items(pos)
    minetest.after(0, function()
        local objects = minetest.get_objects_inside_radius(pos, 2.0)
        for _, obj in ipairs(objects) do
            local luaentity = obj:get_luaentity()
            if luaentity and luaentity.name == "__builtin:item" then
                luaentity._player_dropped = true
                luaentity._drop_time = minetest.get_us_time()
            end
        end
    end)
end

-- Override item drop to support single-item drop (default) and full-stack drop (sneak)
local original_item_drop = minetest.item_drop

minetest.item_drop = function(itemstack, dropper, pos)
    if dropper and dropper:is_player() then
        local ctrl = dropper:get_player_control()
        if not ctrl.sneak then
            -- plain Q: drop only 1 item, keep the rest
            local single = itemstack:take_item(1)
            original_item_drop(single, dropper, pos)
            tag_dropped_items(pos)
            return itemstack  -- remaining stack stays in inventory
        end
        -- sneak+Q: fall through to full stack drop
    end

    -- full stack drop (sneaking or non-player)
    local result = original_item_drop(itemstack, dropper, pos)
    if dropper and dropper:is_player() then
        tag_dropped_items(pos)
    end
    return result
end

-- Pickup: walk over items to collect them
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        local inv = player:get_inventory()

        local objects = minetest.get_objects_inside_radius(pos, PICKUP_RADIUS)
        for _, obj in ipairs(objects) do
            if obj:is_player() then goto continue end

            local luaentity = obj:get_luaentity()
            if luaentity and luaentity.name == "__builtin:item" then
                if luaentity._player_dropped then
                    local age = (minetest.get_us_time() - luaentity._drop_time) / 1000000
                    if age < PLAYER_DROP_PICKUP_DELAY then goto continue end
                end
                local itemstack = ItemStack(luaentity.itemstring)
                if inv:room_for_item("main", itemstack) then
                    inv:add_item("main", itemstack)
                    obj:remove()
                end
            end

            ::continue::
        end
    end
end)