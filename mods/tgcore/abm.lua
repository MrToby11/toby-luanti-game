local function has_water_neighbor(pos)
    local neighbors = {
        {x = pos.x+1, y = pos.y, z = pos.z},
        {x = pos.x-1, y = pos.y, z = pos.z},
        {x = pos.x,   y = pos.y, z = pos.z+1},
        {x = pos.x,   y = pos.y, z = pos.z-1},
        {x = pos.x,   y = pos.y+1, z = pos.z},
        {x = pos.x,   y = pos.y-1, z = pos.z},
    }
    for _, npos in ipairs(neighbors) do
        local name = minetest.get_node(npos).name
        if name == "tgcore:water_source" or name == "tgcore:water_flowing" then
            return true
        end
    end
    return false
end

-- Lava source + water neighbour = stone
minetest.register_abm({
    label = "Lava source cooling",
    nodenames = {"tgcore:lava_source"},
    neighbors = {"tgcore:water_source", "tgcore:water_flowing"},
    interval = 1,
    chance = 1,
    action = function(pos)
        if not has_water_neighbor(pos) then return end
        minetest.set_node(pos, {name = "tgcore:stone"})
    end,
})

-- Flowing lava + water neighbour = stone
minetest.register_abm({
    label = "Flowing lava cooling",
    nodenames = {"tgcore:lava_flowing"},
    neighbors = {"tgcore:water_source", "tgcore:water_flowing"},
    interval = 1,
    chance = 1,
    action = function(pos)
        if not has_water_neighbor(pos) then return end
        minetest.set_node(pos, {name = "tgcore:stone"})
    end,
})