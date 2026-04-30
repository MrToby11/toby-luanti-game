-- Gamemode system
-- Tracks and switches between creative and survival per player

local function set_creative(player)
    local name = player:get_player_name()

    minetest.set_player_privs(name, {
        interact          = true,
        shout             = true,
        fly               = true,
        fast              = true,
        noclip            = true,
        teleport          = true,
        give              = true,
        settime           = true,
        protection_bypass = true,
        zoom              = true,
    })

    -- Disable damage and hunger in creative
    player:set_properties({hp_max = 20})
    player:set_hp(20)

    -- Infinite digging speed in creative
    player:set_physics_override({
        -- digging speed handled separately per tool
    })

    minetest.chat_send_player(name, "Creative mode enabled")
end

local function set_survival(player)
    local name = player:get_player_name()

    minetest.set_player_privs(name, {
        interact = true,
        shout    = true,
        zoom     = true,
    })

    minetest.chat_send_player(name, "Survival mode enabled")
end

-- Store each player's current mode
local player_mode = {}  -- "creative" or "survival"

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()
    local saved_mode = meta:get_string("gamemode")

    if saved_mode ~= "" then
        -- Player has a saved mode from a previous session, use that
        player_mode[name] = saved_mode
    else
        -- First time joining - use the creative mode checkbox to set default
        if minetest.settings:get_bool("creative_mode") then
            player_mode[name] = "creative"
        else
            player_mode[name] = "survival"
        end
    end

    if player_mode[name] == "creative" then
        set_creative(player)
    else
        set_survival(player)
    end
end)

minetest.register_on_leaveplayer(function(player)
    player_mode[player:get_player_name()] = nil
end)

minetest.register_chatcommand("gm", {
    description = "Toggle between creative and survival mode",
    privs = {},  -- any player can use it, since it's singleplayer focused
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        if player_mode[name] == "creative" then
            player_mode[name] = "survival"
            set_survival(player)
        else
            player_mode[name] = "creative"
            set_creative(player)
        end

        -- Persist the mode so it survives relog
        player:get_meta():set_string("gamemode", player_mode[name])
        return true
    end
})