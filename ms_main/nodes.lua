local S = core.get_translator(core.get_current_modname())

core.register_node(":mythisky:kill_block", {
    description = "Kill Block",
    drawtype = "airlike",
    groups = {not_in_creative_inventory = 1},
    drop = "",
    on_blast = function() return end,
    walkable = false,
    pointable = false,
    damage_per_second = 20,
})

core.register_node(":mythisky:springboard", {
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

                    core.sound_play("ms_main_springboard", {
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

core.override_item("wool:red", {
    stack_max = 150
})

core.override_item("wool:blue", {
    stack_max = 150
})

core.override_item("wool:red", {
    stack_max = 150
})

core.override_item("farming:bread", {
    stack_max = 16
})