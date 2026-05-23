-- For now all tgcore crafting recipes live here. Many are temporary.

-- 1 dirt -> 1 grass block
minetest.register_craft({
    output = "tgcore:dirt_with_grass",
    recipe = {
        {"tgcore:dirt"},
    },
})

-- 1 log -> 4 planks
minetest.register_craft({
    output = "tgcore:wooden_planks 4",
    recipe = {
        {"tgcore:wooden_log"},
    },
})

-- 1 plank -> 1 leaves
minetest.register_craft({
    output = "tgcore:leaves",
    recipe = {
        {"tgcore:wooden_planks"},
    },
})

-- 1 cobblestone -> 1 stone
minetest.register_craft({
    output = "tgcore:stone",
    recipe = {
        {"tgcore:cobblestone"},
    },
})