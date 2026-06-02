local S = core.get_translator(core.get_current_modname())

core.register_on_newplayer(function(player)
    local name = player:get_player_name()
    if core.is_singleplayer() then return end
    core.chat_send_all(core.colorize("green", S("Welcome to the server, @1!", name)))
end)

core.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    if core.is_creative_enabled(player_name) then
        return
    end

    skylith.try_tp_to_spawn(player)
    skylith.reset_inventories(player)
    skylith.show_minimap(player, false)
    skylith.reset_health(player)
    if core.global_exists("minigame") and minigame.reset_spectator then
        minigame.reset_spectator(player)
    end
end)

local timer
core.register_globalstep(function(dtime)
    timer = (timer or 0) + dtime
    if timer > 2 then
        timer = 0
        for _, player in ipairs(core.get_connected_players()) do
            local pos = player:get_pos()
            local node_head = core.get_node({x = pos.x, y = pos.y + 1.625, z = pos.z}).name
            local ndef = core.registered_nodes[node_head]

            if (ndef.walkable == nil or ndef.walkable == true)
            and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
            and (ndef.node_box == nil or ndef.node_box.type == "regular")
            and (node_head ~= "ignore")
            and (not core.check_player_privs(player:get_player_name(), {noclip=true})) then
                local hp = player:get_hp()
                if hp > 0 then
                    player:set_hp(hp - 2)
                end
            end
        end
    end
end)