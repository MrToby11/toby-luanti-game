-- Player physics constants
-- Speeds are multipliers on top of minetest.conf base values (1.0 = conf value)
local WALK_SPEED    = 1.0   -- x4.3 for m/s
local SPRINT_SPEED  = WALK_SPEED * 1.3  -- ~30% faster than walking
local SNEAK_SPEED   = 1.5
local JUMP_HEIGHT   = 1.1   -- In blocks
local GRAVITY       = 1.1
local GROUND_ACCEL  = 2.0   -- Acceleration while on ground
local AIR_ACCEL     = 0.9   -- Acceleration while in air

local player_state = {}

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    player_state[name] = {
        sprinting     = false,
    }
    
    player:get_inventory():set_size("main", 32)
    player:set_fov(1.0, true)
end)

minetest.register_on_leaveplayer(function(player)
    player_state[player:get_player_name()] = nil
end)


minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name  = player:get_player_name()
        local state = player_state[name]
        if not state then return end

        local ctrl     = player:get_player_control()

        local is_sneaking  = ctrl.sneak
        local is_sprinting = ctrl.aux1 and ctrl.up and not is_sneaking

        -- Determines if player is sprinting or walking
        local speed_walk_mult = is_sprinting and SPRINT_SPEED or WALK_SPEED

        -- Overrides player physics
        player:set_physics_override({
            speed_walk           = speed_walk_mult,
            speed_crouch         = SNEAK_SPEED,
            jump                 = JUMP_HEIGHT,
            gravity              = GRAVITY,
            sneak                = true,
            sneak_glitch         = false,
            acceleration_default = GROUND_ACCEL,
            acceleration_air     = AIR_ACCEL,
        })

        -- FOV: widen slightly when sprinting, smooth transition
        if is_sprinting ~= state.sprinting then
            state.sprinting = is_sprinting
            player:set_fov(is_sprinting and 1.1 or 1.0, true, 0.15)
        end
    end
end)