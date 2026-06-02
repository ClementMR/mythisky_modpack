function skylith.try_tp_to_spawn(player)
    return ms_utils.player.teleport_to_spawn(player)
end

function skylith.reset_inventories(player)
    ms_utils.player.clear_inventory(player, {
        include_armor = true,
    })
end

function skylith.show_minimap(player, bool)
    ms_utils.player.set_minimap(player, bool)
end

function skylith.reset_health(player)
    ms_utils.player.reset_health(player)
end

local function kill_player()
    if core.is_singleplayer() then return end

    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        if player and pos.y <= skylith.DEATH_LAYER and not core.check_player_privs(player, {creative=true}) then
            player:set_hp(0)
        end
    end

    core.after(2, kill_player)
end

core.after(0.1, kill_player)