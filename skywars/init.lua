skywars = {
    spawns = {},
    game_name = "skywars"
}

local S = core.get_translator(core.get_current_modname())

dofile(core.get_modpath(core.get_current_modname()) .. "/functions.lua")

minigame.register(skywars.game_name, {
    respawn_allowed = false,
    min_players = 2,
    end_match = true,
    load_time = 15,
    map_regen = true,
    map_timer = 600,
    custom_properties = {
        chests = {
            fields = {
                pos = "pos",
                param2 = {"0","1","2","3"}
            }
        },
        loot = {
            fields = {
                min = "number",
                max = "number",
                item = "string"
            }
        }
    },
    on_join = function(player, map_name)
        local player_name = player:get_player_name()
        local spawn = skywars.find_random_spawn(player_name, map_name)
        assert(spawn ~= nil, "Unable to find a spawn for " .. player_name)

        skywars.set_box(spawn, "skywars:box")
        player:set_pos(spawn)
    end,
    on_load = function(map_name, timer)
        local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)
        for _, player in ipairs(minigame.get_players(map)) do
            hud_api.show_actionbar(player, S("Game starts in @1s...", timer), "0x00FF00")

            core.sound_play("skywars_countdown", {to_player = player:get_player_name(), gain = 0.5}, 1)

            skywars.check_distance_and_teleport(player, map_name)
        end
    end,
    on_unload = function(map_name)
        local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)
        for _, player in ipairs(minigame.get_players(map)) do
            hud_api.remove(player, "actionbar")
        end
    end,
    on_start = function(map_name)
        local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)

        for _, player in ipairs(minigame.get_players(map)) do
            if hud_api.get(player, "actionbar") then
                hud_api.remove(player, "actionbar")
            end

            hud_api.show_front(player, S("Game begins – may the best player win!"), "0x00FF00")

            core.sound_play("skywars_countdown_end", {to_player = player:get_player_name(), gain = 1.0}, 1)

            core.after(3, hud_api.remove, player, "front")
        end

        skywars.place_chests(map)
    end,
    on_tick = function(map_name, timer)
        local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)

        for _, player in ipairs(minigame.get_players(map)) do
            local lowest = math.min(map.pos1.y, map.pos2.y)
            if player:get_pos().y < lowest + 10 then player:set_hp(0) end

            if timer <= 30 then
                hud_api.show_actionbar(player, S("@1s left", timer), "0XFFC900")
            end
        end
    end,
    on_end = function(map_name, reason, winners)
        local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)

        local list = {}
        for _, player in ipairs(minigame.get_players(map)) do
            if hud_api.get(player, "actionbar") then
                hud_api.remove(player, "actionbar")
            end

            skywars.clear_armor(player, false)

            skywars.clear_spawn(player:get_player_name(), map_name)

            table.insert(list, player)
        end

        for _, spectator in ipairs(minigame.get_spectators(map)) do
            table.insert(list, spectator)
        end

        if reason == "winner" then
            for _, player in ipairs(list) do
                hud_api.show_front(player, S("The winner is @1 - well played!", winners), "0x8E1DDC")
                core.sound_play("skywars_winner", {to_player = player:get_player_name(), gain = 1.0}, 1)

                core.after(3, hud_api.remove, player, "front")
            end
        end
    end,
    on_die = function(player_name, map_name)
        local player = core.get_player_by_name(player_name)
        local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)

        minigame.chat_send_all(map, S("@1 has been eliminated!", player_name))

        minigame.drop_inventory(player)

        skywars.clear_armor(player, true)

        skywars.clear_spawn(player_name, map_name)

        hud_api.remove_all(player)
    end,
    on_leave = function(player_name, map_name)
        local player = core.get_player_by_name(player_name)

        minigame.drop_inventory(player)

        skywars.clear_armor(player, true)

        skywars.clear_spawn(player_name, map_name)

        hud_api.remove_all(player)
    end,
})

core.register_node("skywars:box", {
    description = "SK Glass",
    drawtype = "glasslike",
	tiles = {"default_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
    groups = {unbreakable=1, not_in_creative_inventory=1},
	on_blast = function() return end,
    on_drop = function() return end,
    sounds = default.node_sound_glass_defaults()
})