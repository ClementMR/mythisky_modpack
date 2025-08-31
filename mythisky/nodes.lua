local S = core.get_translator(core.get_current_modname())

core.register_node("mythisky:kill_block", {
    description = "Kill Block",
    drawtype = "airlike",
    groups = {not_in_creative_inventory = 1},
    drop = "",
    on_blast = function() return end,
    walkable = false,
    pointable = false,
    damage_per_second = 20,
})

core.register_node("mythisky:springboard", {
    description = S("Springboard"),
    drawtype = "mesh",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    collision_box = {
        type = "fixed",
        fixed = {-0.8, -0.5, -1.0, 0.8, -0.45, 1.0},
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.8, -0.5, -1.0, 0.8, -0.45, 1.0},
    },
    tiles = {"wool_red.png"},
    mesh = "pad.obj",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    on_construct = function(pos)
        core.get_node_timer(pos):start(1)
    end,
	on_timer = function(pos)
        for _, obj in pairs(core.get_objects_inside_radius(pos, 2)) do
            if obj:is_player() then
                local player_pos = vector.new(obj:get_pos())
                local node = core.get_node(player_pos)

                if node.name == "mythisky:springboard" then
                    local facedir = node.param2
                    local dir_vector
                    if facedir == 0 then dir_vector = {x = 0, y = 0, z = 1}
                    elseif facedir == 1 then dir_vector = {x = 1, y = 0, z = 0}
                    elseif facedir == 2 then dir_vector = {x = 0, y = 0, z = -1}
                    elseif facedir == 3 then dir_vector = {x = -1, y = 0, z = 0}
                    else dir_vector = {x = 0, y = 0, z = 0} end

                    local velocity = {x = dir_vector.x * 25, y = 15, z = dir_vector.z * 25}
                    obj:add_velocity(velocity)

                    core.sound_play("mythisky_springboard", {
                        pos = pos,
                        gain = 1.0,
                        max_hear_distance = 10
                    })
                end
            end
        end

        return true
    end,
})

local respawn_point = {}

core.register_node("mythisky:echo_stone", {
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

        local spawnpoint = core.setting_get_pos("static_spawnpoint")
        if spawnpoint then
            clicker:set_pos(spawnpoint)
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

local clear_list = {
    "default:chest_locked",
    "doors:door_steel",
    "doors:trapdoor_steel",
    "xpanes:door_steel_bar",
    "xpanes:trapdoor_steel_bar",
    "xdecor:enchantment_table",
    "xdecor:enderchest",
    "doors:prison_door",
    "carts:cart"
}

for _, item in ipairs(clear_list) do
    if core.registered_nodes[item] or core.registered_craftitems[item] then
        core.clear_craft({output = item})
    end
end

core.override_item("default:gravel", {
    drop = "default:gravel"
})

if core.get_modpath("beds") then
    local list = {
        "beds:fancy_bed_bottom",
        "beds:bed_bottom"
    }

    for _, node in ipairs(list) do
        core.override_item(node, {on_rightclick = function() return end})
    end
end

if core.get_modpath("xdecor") then
    core.override_item("xdecor:enchantment_table", {
        groups = {unbreakable=1},
        on_blast = function() return end
    })
end