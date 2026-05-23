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

-- Grasslands: surface only, above beach zone
minetest.register_biome({
    name = "grasslands",
    node_top = "tgcore:dirt_with_grass",
    depth_top = 1,
    node_filler = "tgcore:dirt",
    depth_filler = 3,
    node_stone = "tgcore:stone",
    node_riverbed = "tgcore:sand",
    depth_riverbed = 2,
    y_max = 1000,
    y_min = 3,              -- stops above the beach zone
    heat_point = 50,
    humidity_point = 50,
})

-- Beach: shoreline strip
minetest.register_biome({
    name = "grasslands_beach",
    node_top = "tgcore:sand",
    depth_top = 1,
    node_filler = "tgcore:sand",
    depth_filler = 3,
    node_stone = "tgcore:stone",
    y_max = 2,              -- just above waterline
    y_min = -1,
    heat_point = 50,
    humidity_point = 50,
})

-- Ocean floor: below waterline
minetest.register_biome({
    name = "grasslands_ocean",
    node_top = "tgcore:sand",
    depth_top = 1,
    node_filler = "tgcore:sand",
    depth_filler = 3,
    node_stone = "tgcore:stone",
    y_max = -2,
    y_min = -31000,
    heat_point = 50,
    humidity_point = 50,
})

-- ---------------------------------------------------------------------------
-- Ores (used for underground blob generation too, not just minerals)
-- ---------------------------------------------------------------------------

-- Gravel: large blobs scattered through stone underground
minetest.register_ore({
    ore_type       = "blob",
    ore            = "tgcore:gravel",
    wherein        = {"tgcore:stone"},
    clust_scarcity = 4 * 4 * 4,  -- one blob per ~4096 nodes of stone
    clust_num_ores = 30,             -- nodes per blob
    clust_size     = 5,              -- approximate blob radius
    y_max          = 30,             -- can appear near surface too
    y_min          = -31000,
    noise_params = {
        offset  = 0,
        scale   = 1,
        spread  = {x = 150, y = 150, z = 150},
        seed    = 17,
        octaves = 1,
        persist = 0.5,
    },
})

-- ---------------------------------------------------------------------------
-- Decorations
-- ---------------------------------------------------------------------------

-- Simple tree schematic

local modpath = minetest.get_modpath("tgcore")

minetest.register_decoration({
    deco_type = "schematic",
    place_on  = {"tgcore:dirt_with_grass"},
    sidelen   = 16,
    fill_ratio = 0.003,
    biomes    = {"grasslands"},
    y_max     = 1000,
    y_min     = 3,
    schematic = modpath .. "/schematics/mytree.mts",
    flags     = "place_center_x, place_center_z",
    rotation  = "random",
})



-- ---------------------------------------------------------------------------
-- Water level and mapgen settings (unchanged)
-- ---------------------------------------------------------------------------

minetest.register_lbm({
    name       = "tgcore:set_water_level",
    nodenames  = {"tgcore:water_source"},
    run_at_every_load = false,
    action = function(pos, node)
        if node.param2 == 0 then
            minetest.set_node(pos, {name = "tgcore:water_source", param2 = 8})
        end
    end,
})

minetest.register_on_mapgen_init(function(mgparams)
    minetest.set_mapgen_setting("mg_name", "v7", true)
end)