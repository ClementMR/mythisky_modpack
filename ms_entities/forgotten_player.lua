local S = core.get_translator(core.get_current_modname())

local function valid_positions(pos)
    local valid_pos = {}
    local min, max = -1, 1
    for x=min, max do
        for z=min, max do
            local node_pos = {x=pos.x + x, y=pos.y,z=pos.z + z}
            if core.get_node(node_pos).name == "air" then
                table.insert(valid_pos, node_pos)
            end
        end
    end

    return valid_pos
end

mobs:register_mob("ms_entities:forgotten_player", {
    type = "monster",
    hp_min = 900,
    hp_max = 1000,
    walk_velocity = 2.2,
    run_velocity = 2.8,
    randomly_turn = true,
    jump_height = 1.2,
    view_range = 10,
    damage = 5,
    knock_back = false,
    lava_damage = 4,
    fire_damage = 1,
    suffocation = 1,
    floats = false,
    reach = 4,
    fear_height = 0,
    attack_chance = 0,
    attack_monsters = true,
    attack_animals = true,
    attack_players = true,
    attack_type = "dogfight",
    pathfinding = 1,
    makes_footstep_sound = true,
    visual = "mesh",
    mesh = "character.b3d",
    collisionbox = {-0.3,0,-0.3, 0.3,1.7,0.3},
    textures = {
        "ms_entities_forgotten_player.png",
        "blank.png",
        "default_tool_diamondsword.png^[colorize:purple:125"
    },
    animation = {
        stand_start = 0,
        stand_end = 79,
        stand_speed = 30,

        walk_start = 168,
        walk_end = 187,
        walk_speed = 30,

        run_start = 168,
        run_end = 187,
        run_speed = 33,

        punch_start = 190,
        punch_end = 198,
        punch_speed = 30,
    },
    do_punch = function(self, hitter)
        local ent = self.object
        local ent_pos = vector.round(ent:get_pos())
        local hitter_pos = hitter:get_pos()

        if self.state == "walk" then
            return
        end

        if hitter:get_wielded_item():get_name() == "ms_arena:shotgun" then return end

        if self.state == "attack" then
            local valid_pos = {}
            for _, pos in ipairs(valid_positions(hitter_pos)) do
                local upper_pos = {x=pos.x, y=pos.y + 1, z=pos.z}
                if core.get_node(pos).name == "air" and core.get_node(upper_pos).name == "air" then
                    table.insert(valid_pos, pos)
                end
            end

            if math.random(0, 4) == 1 and #valid_pos > 0 then
                mobs:effect(ent_pos, 10, "default_obsidian_shard.png",
                    1, 1.5, 3, 10, 1, true)

                core.sound_play("ms_entities_forgotten_player", {
                    pos = ent_pos,
                    gain = 0.5,
                    max_hear_distance = 16
                })

                ent:set_pos(valid_pos[math.random(1, #valid_pos)])
                mobs:effect(hitter_pos, 10, "default_mese_crystal_fragment.png",
                    1, 1.5, 3, 10, 1, true)
            end
        end
    end,
    on_death = function(_, killer)
        core.chat_send_player(killer:get_player_name(),
        "<".. core.colorize("green", "Forgotten Player") .."> " .. S("Good game!"))
    end
})

core.register_node("ms_entities:fp_spawner", {
    description = "FP Spawner",
    drawtype = "nodebox",
    tiles = {
        "default_stone.png^ms_entities_head.png",
        "default_stone.png"
    },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {unbreakable=1},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.4, -0.5, -0.4, 0.4, -0.2, 0.4},
        },
    },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", S("Right-click to spawn a mob"))
    end,
    on_rightclick = function(pos)
        for _, obj in ipairs(core.get_objects_inside_radius(pos, 30)) do
            if obj:get_luaentity() and obj:get_luaentity().name == "ms_entities:forgotten_player" then
                obj:remove()
            end
        end

        local new_pos = vector.new(pos)
        new_pos.y = new_pos.y + 1
        core.add_entity(new_pos, "ms_entities:forgotten_player")
    end
})

mobs:register_egg("ms_entities:forgotten_player", "Forgotten Player", "default_cactus_side.png", 1, 1)
mobs:alias_mob("ms_entities:forgotten_player", "forgotten_player")