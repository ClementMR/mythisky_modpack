local function bulletcast(pos1, pos2, objects, liquids)
	core.add_particle({
		pos = pos1,
		velocity = vector.multiply(vector.direction(pos1, pos2), 400),
		acceleration = {x=0, y=0, z=0},
		expirationtime = 0.1,
		size = 1,
		collisiondetection = true,
		collision_removal = true,
		object_collision = objects,
		texture = "ctf_ranged_bullet.png",
		glow = 0
	})

	local raycast = core.raycast(pos1, pos2, objects, liquids)
	local bc = {
		raycast = raycast,
		hit_object_or_node = function(self, options)
			if not options then
				options = {}
			end

			for hitpoint in self.raycast do
				if hitpoint.type == "node" then
					if not options.node or options.node(core.registered_nodes[core.get_node(hitpoint.under).name]) then
						return hitpoint
					end
				elseif hitpoint.type == "object" then
					if not options.object or options.object(hitpoint.ref) then
						return hitpoint
					end
				end
			end
		end,
	}

	setmetatable(bc, {
		__index = function(table, key)
			local not_raycast_func = rawget(table, key)

			if not_raycast_func then
				return not_raycast_func
			else
				return function(self, ...)
					local sraycast = rawget(self, "raycast")

					return sraycast[key](sraycast, ...)
				end
			end
		end,
		__call = function(table, ...)
			return rawget(table, "raycast")(...)
		end
	})

	return bc
end

local shoot_cooldown = ms_items.cooldown()
core.register_tool("ms_arena:shotgun", {
	description =  "Shotgun",
	wield_image = "ctf_ranged_shotgun.png",
	inventory_image = "ctf_ranged_shotgun.png^ms_arena_infinite_item.png",
	on_use = function(_, user)
		if shoot_cooldown:get(user) then
			return
		end

		shoot_cooldown:set(user, 2)

		local look_dir = user:get_look_dir()
		local spawnpos = vector.offset(user:get_pos(), 0, user:get_properties().eye_height, 0)
		spawnpos = vector.add(spawnpos, user:get_eye_offset())
		spawnpos = vector.add(spawnpos, vector.multiply(look_dir, 0.4))

		local amount = 10
		local range = 10
		local spread = 4
		local endpos = vector.add(spawnpos, vector.multiply(look_dir, range))

		local rays = {}
		for i=1, amount do
			rays[i] = bulletcast(
				spawnpos, vector.offset(endpos,
					math.random(-spread, spread),
					math.random(-spread, spread),
					math.random(-spread, spread)
				),
				true, true
			)
		end

	    -- Two copies of SimpleSoundSpec

        local non_user_spec = {}
        non_user_spec.pos = user:get_pos()
        non_user_spec.exclude_player = user:get_player_name()

        local user_spec = {}
        user_spec.to_player = user:get_player_name()

        core.sound_play("ctf_ranged_shotgun", non_user_spec, true)
        core.sound_play("ctf_ranged_shotgun", user_spec, true)

		for _, ray in pairs(rays) do
			local hitpoint = ray:hit_object_or_node({
				node = function(ndef)
					return (ndef.walkable == true and ndef.pointable == true) or ndef.groups.liquid
				end,
				object = function(obj)
					return (obj:is_player() and obj ~= user) or not obj:is_player() and obj:get_luaentity().name ~= "__builtin:item"
				end
			})

            if hitpoint then
                if hitpoint.type == "node" then
                    local node = core.get_node(hitpoint.under)
                    local nodedef = core.registered_nodes[node.name]

                    if nodedef.walkable and nodedef.pointable then
                        core.add_particle({
                            pos = vector.subtract(hitpoint.intersection_point, vector.multiply(look_dir, 0.04)),
                            velocity = vector.new(),
                            acceleration = {x=0, y=0, z=0},
                            expirationtime = 3,
                            size = 1,
                            collisiondetection = false,
                            texture = "ctf_ranged_bullethole.png",
                        })

                        core.sound_play("ctf_ranged_ricochet", {pos = hitpoint.intersection_point})
                    elseif nodedef.groups.liquid then
                        core.add_particlespawner({
                            amount = 10,
                            time = 0.1,
                            minpos = hitpoint.intersection_point,
                            maxpos = hitpoint.intersection_point,
                            minvel = {x=look_dir.x * 3, y=4, z=-look_dir.z * 3},
                            maxvel = {x=look_dir.x * 4, y=6, z= look_dir.z * 4},
                            minacc = {x=0, y=-10, z=0},
                            maxacc = {x=0, y=-13, z=0},
                            minexptime = 1,
                            maxexptime = 1,
                            minsize = 0,
                            maxsize = 0,
                            collisiondetection = false,
                            glow = 3,
                            node = {name = nodedef.name},
                        })
                    end
                elseif hitpoint.type == "object" then
                    hitpoint.ref:punch(user, 2, {
                        full_punch_interval = 2,
                        damage_groups = {fleshy = 1}
                    }, look_dir)
                end
            end
		end
	end,
	on_drop = function() return end
})