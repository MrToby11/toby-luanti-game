-- Hand digging capability

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