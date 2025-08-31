local game_name = "glass_stepping_stones"

local S = core.get_translator(core.get_current_modname())

local function set_barrier() end

minigame.register(game_name, {
    respawn_allowed = false,
    max_players = 16,
    min_players = 2,
    end_match = false,
    load_time = 5,
    map_regen = false,
    map_timer = 200,
    custom_properties = {
        platforms = {fields = {pos = "pos"}},
        barrier_p1 = {fields = {pos = "pos"}},
        barrier_p2 = {fields = {pos = "pos"}}
    },
    on_join = function(player, map_name)
        local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
        local spawns = minigame.get_spawns(map)

        player:set_pos(spawns[1])

        local pos1 = map.barrier_p1
        local pos2 = map.barrier_p2
        if pos1 and pos2 then
            set_barrier(pos1, pos2, "glass_stepping_stones:barrier")
        end
    end,
    on_load = function(map_name, timer)
        if timer > 0 then
            local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
            for _, player in ipairs(minigame.get_players(map)) do
                hud_api.show_actionbar(player, S("Game starts in @1s...", timer), "0xFF0000")
            end
        end
    end,
    on_unload = function(map_name)
        local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
        for _, player in ipairs(minigame.get_players(map)) do
            hud_api.remove(player, "actionbar")
        end
    end,
    on_start = function(map_name)
        local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)

        for _, player in ipairs(minigame.get_players(map)) do
            if hud_api.get(player, "actionbar") then
                hud_api.remove(player, "actionbar")
            end
        end

        if map.platforms then
            local next_real = false
            for i=1, #map.platforms do
                local is_fake = math.random(0, 1) == 1
                local node_name
                if is_fake and not next_real then
                    node_name = "glass_stepping_stones:fake_glass"
                    next_real = true
                else
                    node_name = "glass_stepping_stones:glass"
                    next_real = false
                end

                local platform = map.platforms[i]
                local pos = {
                    {x = platform.x, y = platform.y, z = platform.z},
                    {x = platform.x-1, y = platform.y, z = platform.z},
                    {x = platform.x-1, y = platform.y, z = platform.z+1},
                    {x = platform.x, y = platform.y, z = platform.z+1}
                }

                for _, p in ipairs(pos) do
                    core.set_node(p, {name = node_name})
                end
            end
        end

        local pos1 = map.barrier_p1
        local pos2 = map.barrier_p2
        if pos1 and pos2 then
            set_barrier(pos1, pos2, "air")
        end
    end,
    on_tick = function(map_name)
        local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
        for i, player in ipairs(minigame.get_players(map)) do
            if core.get_node(player:get_pos()).name == "glass_stepping_stones:portal" then
                hud_api.show_front(player, S("Congratulations, you won!"), "0x8E1DDC")

                minigame.reset_player(player)

                table.remove(map.players, i)

                core.after(2, hud_api.remove, player, "front")
            end
        end
    end,
    on_die = function(player_name, map_name)
        local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
        minigame.chat_send_all(map, S("@1 has been eliminated!", player_name))

        hud_api.remove_all(core.get_player_by_name(player_name))
    end,
    on_leave = function(player_name)
        hud_api.remove_all(core.get_player_by_name(player_name))
    end
})

function set_barrier(pos1, pos2, node)
    local min = {
        x = math.min(pos1.x, pos2.x),
        y = math.min(pos1.y, pos2.y),
        z = math.min(pos1.z, pos2.z)
    }
    local max = {
        x = math.max(pos1.x, pos2.x),
        y = math.max(pos1.y, pos2.y),
        z = math.max(pos1.z, pos2.z)
    }

    for x = min.x, max.x do
        for y = min.y, max.y do
            for z = min.z, max.z do
                local pos = {x = x, y = y, z = z}
                core.set_node(pos, {name = node})
            end
        end
    end
end

core.register_node("glass_stepping_stones:portal", {
	description = "GSS Portal",
	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		{
			name = "ms_portal_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.9,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "colorfacedir",
	palette = "ms_portal_portal_palette.png^[colorize:#E717B7",
    groups = {not_in_creative_inventory=1},
	post_effect_color = {a = 160, r = 213, g = 23, b = 183},
	sunlight_propagates = true,
	use_texture_alpha = "blend",
	walkable = false,
	pointable = false,
	is_ground_content = false,
	light_source = 7,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	drop = "",
})

core.register_node("glass_stepping_stones:fake_glass", {
    description = "GSS Fake Glass",
    drawtype = "glasslike",
	tiles = {"default_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "",
    pointable = false,
    walkable = false,
    groups = {not_in_creative_inventory=1},
    sounds = default.node_sound_glass_defaults(),
    on_construct = function(pos)
        core.get_node_timer(pos):start(0.1)
    end,
	on_timer = function(pos)
        for _, obj in pairs(core.get_objects_inside_radius(pos, 2)) do
            if obj:is_player() then
                local player_pos = vector.new(obj:get_pos())
                -- Empêche les spectateurs de casser les blocs
                if minigame.is_spectating(obj) then return end
                if core.get_node(player_pos).name == "glass_stepping_stones:fake_glass" then
                    core.remove_node(pos)
                    core.sound_play("glass_stepping_stones_glass_crack", {gain = 1.0,pos = pos})
                end
            end
        end

        return true
    end,
	on_blast = function() return end
})

core.register_node("glass_stepping_stones:glass", {
    description = "GSS Glass",
    drawtype = "glasslike",
	tiles = {"default_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "",
    pointable = false,
    groups = {not_in_creative_inventory=1},
    sounds = default.node_sound_glass_defaults(),
	on_blast = function() return end
})

core.register_node("glass_stepping_stones:barrier", {
    description = "GSS Barrier",
    drawtype = "glasslike",
	tiles = {"default_glass.png^[colorize:#FF0000:100"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "",
    groups = {not_in_creative_inventory=1},
    sounds = default.node_sound_glass_defaults(),
	on_blast = function() return end
})

core.register_alias("gss_glass", "glass_stepping_stones:glass")
core.register_alias("gss_fake_glass", "glass_stepping_stones:fake_glass")