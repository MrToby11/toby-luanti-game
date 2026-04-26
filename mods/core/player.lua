-- Player physics constants
-- Speeds are multipliers on top of minetest.conf base values (1.0 = conf value)
local WALK_SPEED    = 1.0   -- normal movement
local SPRINT_SPEED  = 1.3   -- ~30% faster than walking
local SNEAK_SPEED   = 1.0   -- conf already sets crouch speed, so 1.0 is correct
local JUMP_HEIGHT   = 1.0   -- conf sets base, keep at 1.0 unless you want per-player changes
local JUMP_COOLDOWN = 0.1   -- seconds before you can jump again after landing

local player_state = {}

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    -- Grants player full privileges
    if name == "singleplayer" then
        minetest.set_player_privs("singleplayer", {
            interact = true, shout = true, fly = true, fast = true,
            noclip = true, teleport = true, privs = true, give = true,
            settime = true, ban = true, kick = true, protection_bypass = true,
        })
    end

    player_state[name] = {
        on_ground     = false,
        sprinting     = false,
        jump_cooldown = 0,
        jump_was_held = false,
    }

    player:set_fov(1.0, true)
end)

minetest.register_on_leaveplayer(function(player)
    player_state[player:get_player_name()] = nil
end)


-- Ground detection: samples four corners of the player's feet
-- Returns true only when feet are firmly planted on top of a solid node
local function is_on_ground(player)
    local pos = player:get_pos()
    local vel = player:get_velocity()

    if vel.y > 0.1 then return false end

    local offsets = {
        {x =  0.0, z =  0.0},
        {x =  0.25, z =  0.25},
        {x = -0.25, z =  0.25},
        {x =  0.25, z = -0.25},
        {x = -0.25, z = -0.25},
    }

    for _, o in ipairs(offsets) do
        local below = minetest.get_node({
            x = math.floor(pos.x + o.x + 0.5),
            y = math.floor(pos.y - 0.1),
            z = math.floor(pos.z + o.z + 0.5),
        })
        local def = minetest.registered_nodes[below.name]
        if def and def.walkable ~= false and below.name ~= "air" then
            local block_top = math.floor(pos.y - 0.05) + 1.0
            if (pos.y - block_top) < 0.3 then
                return true
            end
        end
    end
    return false
end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name  = player:get_player_name()
        local state = player_state[name]
        if not state then return end

        local ctrl     = player:get_player_control()
        local grounded = is_on_ground(player)
        state.on_ground = grounded

        local is_sneaking  = ctrl.sneak
        local is_sprinting = ctrl.aux1 and ctrl.up and not is_sneaking

        -- Speed: walk uses speed_walk, sneak uses speed_crouch (set in conf),
        -- so we only need to override speed_walk for sprinting
        local speed_walk_mult = is_sprinting and SPRINT_SPEED or WALK_SPEED

        -- Jump cooldown: only triggers on fresh key press
        state.jump_cooldown = math.max(0, state.jump_cooldown - dtime)
        if ctrl.jump and not state.jump_was_held and grounded and state.jump_cooldown <= 0 then
            state.jump_cooldown = JUMP_COOLDOWN
        end
        state.jump_was_held = ctrl.jump

        -- Only override what needs to change dynamically per-player.
        -- gravity and acceleration_air are handled by minetest.conf.
        player:set_physics_override({
            speed_walk   = speed_walk_mult,
            speed_crouch = SNEAK_SPEED,
            jump         = JUMP_HEIGHT or 0,
            sneak        = true,
            sneak_glitch = false,
        })

        -- FOV: widen slightly when sprinting, smooth transition
        if is_sprinting ~= state.sprinting then
            state.sprinting = is_sprinting
            player:set_fov(is_sprinting and 1.1 or 1.0, true, 0.15)
        end
    end
end)