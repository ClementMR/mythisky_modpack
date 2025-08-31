core.register_on_joinplayer(function(player) minigame.reset_player(player) end)

core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    local entry = minigame.get_player_entry(player)

    if entry and entry.game and entry.map then
        local game, map = minigame.get_gamedef_and_mapdef(entry.game, entry.map)
        if minigame.is_spectating(player) then
            for i, s in ipairs(minigame.get_spectators(map)) do
                if s == player then
                    minigame.reset_player(player)

                    table.remove(map.spectators, i)

                    break
                end
            end
        else
            for i, p in ipairs(minigame.get_players(map)) do
                if p == player then
                    if game.def.on_leave then game.def.on_leave(player_name, entry.map) end

                    minigame.reset_player(player)

                    table.remove(map.players, i)

                    break
                end
            end
        end

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
            for i, p in ipairs(minigame.get_players(map)) do
                if p == player then
                    if game.def.on_die then
                        game.def.on_die(player_name, entry.map)
                    end

                    minigame.reset_player(player)

                    table.remove(map.players, i)

                    if map_running and (#map.players > 1 or not end_match) then
                        minigame.add_spectator(player, entry.game, entry.map)
                    end

                    return
                end
            end
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