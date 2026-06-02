core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    local entry = minigame.get_player_entry(player)

    if entry and entry.game and entry.map then
        local game, map = minigame.get_gamedef_and_mapdef(entry.game, entry.map)
        minigame.remove_player_from_map(player, map, {
            before_reset = function(is_spectator)
                if not is_spectator then
                    if game.def.on_leave then game.def.on_leave(player_name, entry.map) end
                end
            end,
        })

        core.log("action", "[Minigame] " .. player_name .. " left the map \"" .. entry.map .. "\"")
    end
end)

core.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()
    local entry = minigame.get_player_entry(player)

    if entry and entry.game and entry.map and not minigame.is_spectating(player) then
        local game, map = minigame.get_gamedef_and_mapdef(entry.game, entry.map)
        local map_info = minigame.get_map_information(game, map)
        local respawn_allowed = map_info.respawn_allowed
        local map_running = map_info.running
        local end_match = map_info.end_match

        if not respawn_allowed then
            local removed = minigame.remove_player_from_map(player, map, {
                before_reset = function()
                    if game.def.on_die then
                        game.def.on_die(player_name, entry.map)
                    end
                end,
            })

            if removed and map_running and (#map.players > 1 or not end_match) then
                minigame.add_spectator(player, entry.game, entry.map)
            end

            return
        end
    end
end)

core.register_on_respawnplayer(function(player)
    local entry = minigame.get_player_entry(player)

    if entry and entry.game and entry.map then
        local _, map = minigame.get_gamedef_and_mapdef(entry.game, entry.map)
        minigame.teleport_player_to_spawn(player, map, 1)
    end
end)

core.register_on_player_hpchange(function(player, hp_change)
    if minigame.is_spectating(player) and hp_change < 0 then
        return 0 -- Cancel damage
    end

    return hp_change
end, true)