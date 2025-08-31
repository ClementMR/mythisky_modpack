local cooldown = ms_items.cooldown()

local S = core.get_translator(core.get_current_modname())

core.register_craftitem("ms_items:snowball", {
    description = S("Snowball"),
	inventory_image = "default_snowball.png",
    stack_max = 16,
    on_use = function(_, player, pointed_thing)
        if cooldown:get(player) then
            return
        else
            cooldown:set(player, 0.5)
        end

        if pointed_thing.type ~= "node" then
            local throw_pos_offset = vector.add({x=0, y=1.5, z=0}, player:get_pos())
            core.add_entity(throw_pos_offset, "ms_items:thrown_snowball", player:get_player_name())
            core.sound_play("ms_items_snowball_thrown", {max_hear_distance = 10, pos = throw_pos_offset})

            local name = player:get_player_name()
            if not core.is_creative_enabled(name) then
                player:get_inventory():remove_item("main", "ms_items:snowball")
            end
        end
    end,
})

local callbacks = {}
core.register_entity("ms_items:thrown_snowball", {
    initial_properties = {
        hp_max = 1,
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.15, -0.15, -0.15, 0.15, 0.15, 0.15},
        visual = "wielditem",
        visual_size = {x = 0.4, y = 0.4},
        textures = {"ms_items:snowball"},
        pointable = false,
        speed = 32,
        gravity = 30,
        damage = 1,
        lifetime = 10
    },
    player_name = "",
    on_step = function(self, _, moveresult)
        if moveresult.collisions then
            for _, collision in ipairs(moveresult.collisions) do
                if collision.type == "object" then
                    local obj = collision.object
                    -- Vérifie si l'objet est bien un joueur
                    if obj and obj:is_player() then
                        obj:punch(core.get_player_by_name(self.player_name), 1.0, {
                            full_punch_interval = 1.0,
                            damage_groups = {fleshy = self.initial_properties.damage}
                        }, nil)
                        self.object:remove()
                        return
                    end
                end
            end
        end

        local collided_with_node = moveresult.collisions[1] and moveresult.collisions[1].type == "node"
        if collided_with_node then
            for i=1, #callbacks do
                local node = core.get_node(moveresult.collisions[1].node_pos)
                callbacks[i](node)
            end
            self.object:remove()
        end
    end,
    on_activate = function(self, staticdata)
        if not staticdata or not core.get_player_by_name(staticdata) then
            self.object:remove()
            return
        end

        self.player_name = staticdata
        local player = core.get_player_by_name(staticdata)
        local yaw = player:get_look_horizontal()
        local pitch = player:get_look_vertical()
        local dir = player:get_look_dir()

        self.object:set_rotation({x = -pitch, y = yaw, z = 0})
        self.object:set_velocity({
            x=(dir.x * self.initial_properties.speed),
            y=(dir.y * self.initial_properties.speed),
            z=(dir.z * self.initial_properties.speed),
        })

        self.object:set_acceleration({x=dir.x*-8, y=-self.initial_properties.gravity, z=dir.z*-8})

        -- Supprime l'entité après un certain temps
        core.after(self.initial_properties.lifetime, function() self.object:remove() end)
    end,
})