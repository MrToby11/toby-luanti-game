-- All terrain generation lives here

-- Mapgen aliases
minetest.register_alias("mapgen_stone",              "tgcore:stone")
minetest.register_alias("mapgen_dirt",               "tgcore:dirt")
minetest.register_alias("mapgen_dirt_with_grass",    "tgcore:dirt_with_grass")
minetest.register_alias("mapgen_water_source",       "tgcore:water_source")
minetest.register_alias("mapgen_river_water_source", "tgcore:water_source")
minetest.register_alias("mapgen_water_flowing",      "tgcore:water_flowing")
minetest.register_alias("mapgen_lava_source",        "tgcore:lava_source")


-- Biomes
minetest.register_biome({
    name = "grasslands",
    node_top = "tgcore:dirt_with_grass",
    depth_top = 1,
    node_filler = "tgcore:dirt",
    depth_filler = 3,
    node_stone = "tgcore:stone",
    y_max = 1000,
    y_min = -3,
    heat_point = 50,
    humidity_point = 50,
})

-- For water level lowering
minetest.register_lbm({
    name       = "tgcore:set_water_level",
    nodenames  = {"tgcore:water_source"},
    run_at_every_load = false,   -- only on newly generated chunks
    action = function(pos, node)
        if node.param2 == 0 then
            minetest.set_node(pos, {name = "tgcore:water_source", param2 = 8})
        end
    end,
}) 

-- Mapgen settings
minetest.register_on_mapgen_init(function(mgparams)
    minetest.set_mapgen_setting("mg_name", "v7", true)
end)