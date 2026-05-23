-- This file is for all core nodes

minetest.register_node("tgcore:stone", {
    description = "Stone",
    tiles = {"tgcore_stone.png"},
    groups = {cracky = 3},
    drop = "tgcore:cobblestone",
})

minetest.register_node("tgcore:cobblestone", {
    description = "Cobblestone",
    tiles = {"tgcore_cobblestone.png"},
    groups = {cracky = 3},
    drop = "tgcore:cobblestone",
})

minetest.register_node("tgcore:dirt", {
    description = "Dirt",
    tiles = {"tgcore_dirt.png"},
    groups = {crumbly = 3},
    drop = "tgcore:dirt",
})

minetest.register_node("tgcore:dirt_with_grass", {
    description = "Grass Block",
    tiles = {"tgcore_grass_top.png", "tgcore_dirt.png", "tgcore_grass_side.png"},
    groups = {crumbly = 3},
    drop = "tgcore:dirt",
})

minetest.register_node("tgcore:gravel", {
    description = "Gravel",
    tiles = {"tgcore_gravel.png"},
    groups = {crumbly = 2, falling_node = 1},
    drop = "tgcore:gravel",
})

minetest.register_node("tgcore:sand", {
    description = "Sand",
    tiles = {"tgcore_sand.png"},
    groups = {crumbly = 3, falling_node = 1},     -- as easy to dig as dirt
    drop = "tgcore:sand",
})

minetest.register_node("tgcore:wooden_log", {
    description = "Wooden Log",
    -- top/bottom face, then side face
    tiles = {"tgcore_wooden_log_top.png", "tgcore_wooden_log_top.png", "tgcore_wooden_log_side.png"},
    paramtype2 = "facedir",     -- allows logs to be placed on their side
    groups = {choppy = 2, flammable = 2},
    drop = "tgcore:wooden_log",
    sounds = {},
})
 
minetest.register_node("tgcore:wooden_planks", {
    description = "Wooden Planks",
    tiles = {"tgcore_wooden_planks.png"},
    groups = {choppy = 2, flammable = 2},
    drop = "tgcore:wooden_planks",
    sounds = {},    -- placeholder until you add wood sounds
})

minetest.register_node("tgcore:leaves", {
    description = "Leaves",
    drawtype = "allfaces_optional",  -- renders inner faces, looks better for leaf clusters
    tiles = {"tgcore_leaves.png"},
    use_texture_alpha = "clip",      -- hard transparency, no blending artifacts
    paramtype = "light",             -- lets light pass through
    waving = 1,                      -- leaves sway in wind if waving is enabled
    groups = {snappy = 3, flammable = 2, leaves = 1},
    drop = "",                       -- no drop by default; add shears later for silk touch
    sounds = {},
})

minetest.register_node("tgcore:water_source", {
    description = "Water",
    drawtype = "liquid",
    tiles = {"tgcore_water.png"},
    special_tiles = {
    {name = "tgcore_water.png", animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}},
    {name = "tgcore_water.png", animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}},
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    pointable = false,              -- crosshair passes through to blocks behind
    on_rightclick = function(pos, node, clicker, itemstack)
        -- Only respond to empty bucket
        if itemstack:get_name() ~= "bucket:bucket_empty" then
            return itemstack
        end
        -- Hand off to bucket pickup logic
        local liquiddef = bucket.liquids[node.name]
        if not liquiddef or not liquiddef.itemname then return itemstack end
        minetest.add_node(pos, {name = "air"})
        return ItemStack(liquiddef.itemname)
    end,
    liquidtype = "source",
    liquid_alternative_flowing = "tgcore:water_flowing",
    liquid_alternative_source  = "tgcore:water_source",
    liquid_range = 7,
    liquid_viscosity = 1,           -- controls movement resistance and spread speed
    liquid_move_physics = true,     -- enables engine-side swim physics
    drowning = 1,                   -- causes breath loss when submerged
    post_effect_color = {a = 200, r = 30, g = 60, b = 90},
    diggable = false,
    is_ground_content = false,
    drop = "",
    groups = {water = 3, liquid = 3},
})

minetest.register_node("tgcore:water_flowing", {
    description = "Flowing Water",
    drawtype = "flowingliquid",
    tiles = {"tgcore_water.png"},
    special_tiles = {
        {name = "tgcore_water.png", backface_culling = false},
        {name = "tgcore_water.png", backface_culling = false},
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    pointable = false,
    liquidtype = "flowing",
    liquid_alternative_flowing = "tgcore:water_flowing",
    liquid_alternative_source  = "tgcore:water_source",
    liquid_range = 7,
    liquid_viscosity = 1,
    liquid_move_physics = true,
    drowning = 1,
    post_effect_color = {a = 200, r = 30, g = 60, b = 90},
    diggable = false,
    is_ground_content = false,
    drop = "",
    groups = {water = 3, liquid = 3},
})

minetest.register_node("tgcore:lava_source", {
    description = "Lava",
    drawtype = "liquid",
    tiles = {"tgcore_lava.png"},
    special_tiles = {
    {name = "tgcore_lava.png", animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}},
    {name = "tgcore_lava.png", animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}},
    },
    paramtype = "light",
    light_source = 13,
    walkable = false,
    buildable_to = true,
    pointable = false,
    liquid_renewable = false,
    on_rightclick = function(pos, node, clicker, itemstack)
        -- Only respond to empty bucket
        if itemstack:get_name() ~= "bucket:bucket_empty" then
            return itemstack
        end
        -- Hand off to bucket pickup logic
        local liquiddef = bucket.liquids[node.name]
        if not liquiddef or not liquiddef.itemname then return itemstack end
        minetest.add_node(pos, {name = "air"})
        return ItemStack(liquiddef.itemname)
    end,
    liquidtype = "source",
    liquid_alternative_flowing = "tgcore:lava_flowing",
    liquid_alternative_source  = "tgcore:lava_source",
    liquid_range = 4,
    liquid_viscosity = 7,           -- lava is much more viscous than water
    liquid_move_physics = true,
    damage_per_second = 8,          -- burns the player
    post_effect_color = {a = 220, r = 255, g = 64, b = 0},
    diggable = false,
    is_ground_content = false,
    drop = "",
    groups = {lava = 3, liquid = 3},
})

minetest.register_node("tgcore:lava_flowing", {
    description = "Flowing Lava",
    drawtype = "flowingliquid",
    tiles = {"tgcore_lava.png"},
    special_tiles = {
        {name = "tgcore_lava.png", backface_culling = false},
        {name = "tgcore_lava.png", backface_culling = false},
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    light_source = 13,
    walkable = false,
    buildable_to = true,
    pointable = false,
    liquid_renewable = false,
    liquidtype = "flowing",
    liquid_alternative_flowing = "tgcore:lava_flowing",
    liquid_alternative_source  = "tgcore:lava_source",
    liquid_range = 4,
    liquid_viscosity = 7,
    liquid_move_physics = true,
    drowning = 1,
    post_effect_color = {a = 220, r = 255, g = 64, b = 0},
    diggable = false,
    is_ground_content = false,
    drop = "",
    groups = {water = 3, liquid = 3},
})