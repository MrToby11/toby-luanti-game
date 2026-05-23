-- Prevent placing nodes inside the player's own collision box
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    if not placer or not placer:is_player() then return end

    local ppos = placer:get_pos()  -- feet position

    -- Player collision box spans from feet (0) to +1.75 in Y,
    -- and ±0.3 in X/Z (Luanti default player box)
    local player_box = {
        min = { x = ppos.x - 0.3, y = ppos.y,        z = ppos.z - 0.3 },
        max = { x = ppos.x + 0.3, y = ppos.y + 1.75,  z = ppos.z + 0.3 },
    }

    -- Node occupies a full 1×1×1 cube at pos
    local node_box = {
        min = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
        max = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
    }

    -- AABB overlap check
    local overlap =
        player_box.min.x < node_box.max.x and player_box.max.x > node_box.min.x and
        player_box.min.y < node_box.max.y and player_box.max.y > node_box.min.y and
        player_box.min.z < node_box.max.z and player_box.max.z > node_box.min.z

    if overlap then
        -- Undo the placement
        minetest.remove_node(pos)
        -- Return the item to the player's hand
        return itemstack
    end
end)