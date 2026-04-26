-- All terrain generation lives here

-- Mapgen aliases
minetest.register_alias("mapgen_stone",              "core:stone")
minetest.register_alias("mapgen_dirt",               "core:dirt")
minetest.register_alias("mapgen_dirt_with_grass",    "core:dirt_with_grass")
minetest.register_alias("mapgen_water_source",       "core:water_source")
minetest.register_alias("mapgen_river_water_source", "core:water_source")
minetest.register_alias("mapgen_water_flowing",      "core:water_flowing")
minetest.register_alias("mapgen_lava_source",        "core:lava_source")


-- Biomes
minetest.register_biome({
    name = "grasslands",
    node_top = "core:dirt_with_grass",
    depth_top = 1,
    node_filler = "core:dirt",
    depth_filler = 3,
    node_stone = "core:stone",
    y_max = 1000,
    y_min = -3,
    heat_point = 50,
    humidity_point = 50,
})


-- Mapgen settings
minetest.register_on_mapgen_init(function(mgparams)
    minetest.set_mapgen_setting("mg_name", "v7", true)
end)