-- Minetest Game mod: bucket
-- See README.txt for licensing and other information.

minetest.register_craft({
	output = "bucket:bucket_empty 1",
	recipe = {
		{"tgcore:stone", "", "tgcore:stone"},
		{"", "tgcore:stone", ""},
	}
})

bucket = {}
bucket.liquids = {}

local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

local function log_action(pos, name, action)
	minetest.log("action", (name ~= "" and name or "A mod")
		.. " " .. action .. " at " .. minetest.pos_to_string(pos) .. " with a bucket")
end

-- Register a new liquid
--    source = name of the source node
--    flowing = name of the flowing node
--    itemname = name of the new bucket item (or nil if liquid is not takeable)
--    inventory_image = texture of the new bucket item (ignored if itemname == nil)
--    name = text description of the bucket item
--    groups = (optional) groups of the bucket item, for example {water_bucket = 1}
--    force_renew = (optional) bool. Force the liquid source to renew if it has a
--                  source neighbour, even if defined as 'liquid_renewable = false'.
--                  Needed to avoid creating holes in sloping rivers.
-- This function can be called from any mod (that depends on bucket).
function bucket.register_liquid(source, flowing, itemname, inventory_image, name,
		groups, force_renew)
	local itemname_raw = itemname
	itemname = itemname and itemname:match("^:(.+)") or itemname
	bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = itemname,
		force_renew = force_renew,
	}
	bucket.liquids[flowing] = bucket.liquids[source]

	if itemname ~= nil then
		minetest.register_craftitem(itemname_raw, {
			description = name,
			inventory_image = inventory_image,
			stack_max = 1,
			groups = groups,

			on_place = function(itemstack, user, pointed_thing)
				-- Must be pointing to node
				if pointed_thing.type ~= "node" then
					return
				end

				local node = minetest.get_node_or_nil(pointed_thing.under)
				local ndef = node and minetest.registered_nodes[node.name]

				-- Call on_rightclick if the pointed node defines it
				if ndef and ndef.on_rightclick and
						not (user and user:is_player() and
						user:get_player_control().sneak) then
					return ndef.on_rightclick(
						pointed_thing.under,
						node, user,
						itemstack)
				end

				local lpos

				-- Check if pointing to a buildable node
				if ndef and ndef.buildable_to then
					-- buildable; replace the node
					lpos = pointed_thing.under
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced

					lpos = pointed_thing.above
					node = minetest.get_node_or_nil(lpos)
					local above_ndef = node and minetest.registered_nodes[node.name]

					if not above_ndef or not above_ndef.buildable_to then
						-- do not remove the bucket with the liquid
						return itemstack
					end
				end

				local pname = user and user:get_player_name() or ""
				if check_protection(lpos, pname, "place "..source) then
					return
				end

				minetest.set_node(lpos, {name = source})
				log_action(lpos, pname, "placed " .. source)
				return ItemStack("bucket:bucket_empty")
			end
		})
	end
end

minetest.register_craftitem("bucket:bucket_empty", {
    description = "Empty Bucket",
    inventory_image = "bucket_empty.png",
    groups = {tool = 1},
    liquids_pointable = true,  -- targets all liquids; flowing ones are filtered below
    on_place = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "object" then
            pointed_thing.ref:punch(user, 1.0, { full_punch_interval=1.0 }, nil)
            return user:get_wielded_item()
        elseif pointed_thing.type ~= "node" then
            -- do nothing if it's neither object nor node
            return
        end

        local pos = pointed_thing.under
        local node = minetest.get_node(pos)
        local liquiddef = bucket.liquids[node.name]

        -- If pointing at flowing liquid, look through it for a source node
        if liquiddef and node.name == liquiddef.flowing then
            local look_dir = user:get_look_dir()
            local eye_pos = user:get_pos()
            eye_pos.y = eye_pos.y + 1.5  -- eye height

            local ray = minetest.raycast(eye_pos, {
                x = eye_pos.x + look_dir.x * 5,
                y = eye_pos.y + look_dir.y * 5,
                z = eye_pos.z + look_dir.z * 5,
            }, false, true)  -- false = skip objects, true = include liquids

            local found_source = false
            for pointed in ray do
                if pointed.type == "node" then
                    local behind_node = minetest.get_node(pointed.under)
                    local behind_def = bucket.liquids[behind_node.name]
                    if behind_def and behind_node.name == behind_def.source then
                        -- Found a source node, redirect pickup to it
                        pos = pointed.under
                        node = behind_node
                        liquiddef = behind_def
                        found_source = true
                        break
                    end
                end
            end

            -- No source found behind flowing node, do nothing
            if not found_source then
                return itemstack
            end
        end

        local item_count = user:get_wielded_item():get_count()

        -- Check if pointing to a liquid source
        if liquiddef ~= nil
        and liquiddef.itemname ~= nil
        and node.name == liquiddef.source then
            local pname = user:get_player_name()
            if check_protection(pos, pname, "take ".. node.name) then
                return
            end

            -- default set to return filled bucket
            local giving_back = liquiddef.itemname

            -- check if holding more than 1 empty bucket
            if item_count > 1 then
                -- if space in inventory add filled bucket, otherwise drop as item
                local inv = user:get_inventory()
                if inv:room_for_item("main", {name=liquiddef.itemname}) then
                    inv:add_item("main", liquiddef.itemname)
                else
                    local upos = user:get_pos()
                    upos.y = math.floor(upos.y + 0.5)
                    minetest.add_item(upos, liquiddef.itemname)
                end
                -- set to return empty buckets minus 1
                giving_back = "bucket:bucket_empty "..tostring(item_count-1)
            end

            -- force_renew requires a source neighbour
            local source_neighbor = false
            if liquiddef.force_renew then
                source_neighbor =
                    minetest.find_node_near(pos, 1, liquiddef.source)
            end
            if source_neighbor and liquiddef.force_renew then
                log_action(pos, pname, "picked up " .. liquiddef.source .. " (force renewed)")
            else
                minetest.add_node(pos, {name = "air"})
                log_action(pos, pname, "picked up " .. liquiddef.source)
            end

            return ItemStack(giving_back)
        end

        -- pointing at a non-liquid node, do nothing
        return itemstack
    end,
})

bucket.register_liquid(
	"tgcore:water_source",
	"tgcore:water_flowing",
	"bucket:bucket_water",
	"bucket_water.png",
	"Water Bucket",
	{tool = 1, water_bucket = 1}
)

bucket.register_liquid(
	"tgcore:lava_source",
	"tgcore:lava_flowing",
	"bucket:bucket_lava",
	"bucket_lava.png",
	"Lava Bucket",
	{tool = 1}
)
--[[ For using lava as a fuel source
minetest.register_craft({
	type = "fuel",
	recipe = "bucket:bucket_lava",
	burntime = 60,
	replacements = {{"bucket:bucket_lava", "bucket:bucket_empty"}},
})
]]