-- Item despawn timer
local ITEM_DESPAWN_TIME = 300  -- 5 minutes

local item_entity = minetest.registered_entities["__builtin:item"]
if item_entity then
    local old_on_step = item_entity.on_step
        item_entity.on_step = function(self, dtime, moveresult)
            local real_age = self.age or 0
            self.age = 0  -- prevent engine TTL from firing
            old_on_step(self, dtime, moveresult)
            self.age = real_age + dtime  -- restore and increment our own tracker
            if self.age > ITEM_DESPAWN_TIME then
                self.object:remove()
            end
        end
end

-- Item drop and pickup system
local PICKUP_RADIUS = 1.5
local PLAYER_DROP_PICKUP_DELAY = 2.0  -- seconds before player-dropped items can be picked up

-- Disable punch-to-pickup on dropped items
local item_entity = minetest.registered_entities["__builtin:item"]
if item_entity then
    local old_on_punch = item_entity.on_punch
    item_entity.on_punch = function(self, hitter)
        -- do nothing; pickup is handled by walking over items
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
local original_item_drop = core.item_drop

core.item_drop = function(itemstack, dropper, pos)
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