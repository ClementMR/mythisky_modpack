function ms_main.try_tp_to_spawn(player)
    return ms_utils.player.teleport_to_spawn(player)
end

function ms_main.reset_inventories(player)
    ms_utils.player.clear_inventory(player, {
        include_armor = true,
    })
end

function ms_main.show_minimap(player, bool)
    ms_utils.player.set_minimap(player, bool)
end


local function kill_player()
    if core.is_singleplayer() then return end

    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        if player and pos.y <= ms_main.DEATH_LAYER and not core.check_player_privs(player, {creative=true}) then
            player:set_hp(0)
        end
    end

    core.after(2, kill_player)
end

core.after(0.1, kill_player)