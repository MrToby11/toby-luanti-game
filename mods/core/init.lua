-- Core mod
-- Registers basic nodes, mapgen and core game logic


-- Grant full privileges to singleplayer automatically
minetest.register_on_joinplayer(function(player)
    if player:get_player_name() == "singleplayer" then
        minetest.set_player_privs("singleplayer", {
            interact = true, shout = true, fly = true, fast = true,
            noclip = true, teleport = true, privs = true, give = true,
            settime = true, ban = true, kick = true, protection_bypass = true,
        })
    end
end)


-- Hand digging
minetest.register_item(":", {
    type = "none",
    wield_image = "wieldhand.png",
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            crumbly = {times={[1]=2.0, [2]=1.0, [3]=0.5}, uses=0, maxlevel=3},
            cracky  = {times={[1]=4.0, [2]=2.0, [3]=1.0}, uses=0, maxlevel=3},
            snappy  = {times={[1]=2.0, [2]=1.0, [3]=0.5}, uses=0, maxlevel=3},
        },
        damage_groups = {fleshy=1},
    }
})


-- Nodes
minetest.register_node("core:stone", {
    description = "Stone",
    tiles = {"core_stone.png"},
    groups = {cracky = 3},
    drop = "core:stone",
})

minetest.register_node("core:dirt", {
    description = "Dirt",
    tiles = {"core_dirt.png"},
    groups = {crumbly = 3},
    drop = "core:dirt",
})

minetest.register_node("core:dirt_with_grass", {
    description = "Grass Block",
    tiles = {"core_grass.png", "core_dirt.png", "core_grass_side.png"},
    groups = {crumbly = 3},
    drop = "core:dirt",
})

minetest.register_node("core:water_source", {
    description = "Water",
    drawtype = "liquid",
    tiles = {"core_water.png"},
    special_tiles = {"core_water.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    liquidtype = "source",
    liquid_alternative_flowing = "core:water_flowing",
    liquid_alternative_source = "core:water_source",
    groups = {water = 3, liquid = 3},
})

minetest.register_node("core:water_flowing", {
    description = "Flowing Water",
    drawtype = "flowingliquid",
    tiles = {"core_water.png"},
    special_tiles = {"core_water.png"},
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    liquidtype = "flowing",
    liquid_alternative_flowing = "core:water_flowing",
    liquid_alternative_source = "core:water_source",
    groups = {water = 3, liquid = 3},
})

minetest.register_node("core:lava_source", {
    description = "Lava",
    drawtype = "liquid",
    tiles = {"core_lava.png"},
    special_tiles = {"core_lava.png"},
    paramtype = "light",
    light_source = 13,
    walkable = false,
    liquidtype = "source",
    liquid_alternative_flowing = "core:lava_source",
    liquid_alternative_source = "core:lava_source",
    groups = {lava = 3, liquid = 3},
})


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