local discord_enabled = core.global_exists("discord")

local function is_ingame(player)
    return minigame.is_player_in_game(player)
end

-- Handle chat messages
core.register_on_chat_message(function(name, message)
    local player = core.get_player_by_name(name)
    local entry = minigame.get_player_entry(player)
    local message_format = "<" .. name .. "> " .. message

    if entry and entry.game and entry.map then
        local _, map = minigame.get_gamedef_and_mapdef(entry.game, entry.map)

        if minigame.is_spectating(player) then
            message_format = core.colorize("grey", "[Spectator] <" .. name .. "> " .. message)
            minigame.chat_send_spectators(map, message_format)

            core.log("action", "SPEC: (".. entry.map ..") <" .. name .. "> " .. message)
        else
            message_format = core.colorize("grey", "[" .. entry.map .. "]") .. " <" .. name .. "> " .. message
            minigame.chat_send_players(map, message_format)

            if discord_enabled then discord.send("[" .. entry.map .. "] <" .. name .. "> " .. message) end

            core.log("action", "CHAT: (".. entry.map ..") <" .. name .. "> " .. message)
        end

        return true
    else
        ms_utils.chat.send_to_connected(message_format, function(connected_player)
            return not is_ingame(connected_player)
        end)

        if discord_enabled then discord.send(message_format) end

        core.log("action", "CHAT: " .. message_format)

        return true
    end
end)