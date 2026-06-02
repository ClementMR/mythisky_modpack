local respawn_point = {}

local S = core.get_translator(core.get_current_modname())

core.register_node("echo_stone:echo_stone", {
    description = "Echo Stone",
    drawtype = "mesh",
    mesh = "echo_stone.obj",
    tiles = {"default_stone.png"},
    groups = {cracky=2},
    sunlight_propagates = true,
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.75, 0.25}
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.75, 0.25}
    },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        core.get_node_timer(pos):start(0.1)
        meta:set_string("infotext", S("Punch to respawn here@n@nRight-click to teleport to lobby"))
    end,
    on_punch = function(pos, _, puncher)
        if core.check_player_privs(puncher, {protection_bypass=true})
        and puncher:get_wielded_item():get_name() == "ms_items:multitool" then
            return
        end

        local name = puncher:get_player_name()
        if respawn_point[name] == pos then
            core.chat_send_player(name, core.colorize("grey", "[ Echo Stone ] ") ..
                S("Respawn point already defined here!"))
            return
        end

        respawn_point[name] = pos
        core.chat_send_player(name, core.colorize("grey", "[ Echo Stone ] ") ..
            S("Respawn point defined!"))
    end,
    on_rightclick = function(_, _, clicker)
        local name = clicker:get_player_name()
        if respawn_point[name] then
            respawn_point[name]= nil
        end

        if ms_utils.player.teleport_to_spawn(clicker) then
            core.chat_send_player(name, core.colorize("grey", "[ Echo Stone ] ") .. S("Teleported to lobby"))
        end
    end
})

core.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local rp = respawn_point[name]
    if rp then
        local pos = {x=rp.x, y=rp.y, z=rp.z+1}
        player:set_pos(pos)
    end
end)

core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    if respawn_point[player_name] then
        respawn_point[player_name] = nil
    end
end)