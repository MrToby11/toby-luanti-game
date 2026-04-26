-- This file is for all core nodes

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