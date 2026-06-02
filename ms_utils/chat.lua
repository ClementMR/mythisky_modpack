ms_utils.chat = {}

function ms_utils.chat.send_to_names(names, message)
    if type(names) ~= "table" then
        return
    end

    for _, name in ipairs(names) do
        core.chat_send_player(name, message)
    end
end

function ms_utils.chat.send_to_players(players, message)
    if type(players) ~= "table" then
        return
    end

    for _, player in ipairs(players) do
        if player then
            core.chat_send_player(player:get_player_name(), message)
        end
    end
end

function ms_utils.chat.send_to_connected(message, predicate)
    for _, player in ipairs(core.get_connected_players()) do
        if not predicate or predicate(player) then
            core.chat_send_player(player:get_player_name(), message)
        end
    end
end
