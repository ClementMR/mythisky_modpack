local current_crosshair = {}

local S = core.get_translator(core.get_current_modname())

ms_settings.register("custom_crosshair", {
    type = "bool",
    default = false,
    label = S("Use custom crosshair"),
    category = "Hud"
})

core.register_globalstep(function()
    for _, player in pairs(core.get_connected_players()) do
        local player_name = player:get_player_name()

        if ms_settings.get(player, "custom_crosshair") then
            local start_pos = vector.add(player:get_pos(), {x=0, y=1.625, z=0})
            local end_pos = vector.add(start_pos, vector.multiply(player:get_look_dir(), 4))
            local raycast = Raycast(start_pos, end_pos, true, false)

            local crosshair_type = "normal"

            for pointed_thing in raycast do
                if pointed_thing.type == "object" and pointed_thing.ref:get_player_name() ~= player_name then
                    crosshair_type = "object"
                    break
                end
            end

            local current = current_crosshair[player_name]

            if not current or current.type ~= crosshair_type then
                if current then player:hud_remove(current.id) end

                player:hud_set_flags({crosshair = false})

                local texture = crosshair_type == "object"
                    and "custom_crosshair_object_crosshair.png"
                    or "custom_crosshair_crosshair.png"

                current_crosshair[player_name] = {
                    id = player:hud_add({
                        type = "image",
                        text = texture,
                        scale = {x = 1, y = 1},
                        position = {x = 0.5, y = 0.5},
                    }),
                    type = crosshair_type
                }
            end
        else
            local current = current_crosshair[player_name]
            if current then
                player:hud_remove(current.id)
                player:hud_set_flags({crosshair = true})

                current_crosshair[player_name] = nil
            end
        end
    end
end)

core.register_on_leaveplayer(function(player)
    if ms_settings.get(player, "custom_crosshair") then
        current_crosshair[player:get_player_name()] = nil
    end
end)