local minigame_editor = {}

core.register_privilege("map_editor", {
    description = "Allows the player to edit a map",
    give_to_singleplayer = true,
})

local editor_prefix = core.colorize("#C82909", "[Map Editor] ")

local function is_vector() end

local function show_homepage(player)
    local games = table.concat(minigame.get_all_games(), ",")
    local form = "size[10,7]" ..
        "box[2.5,0;5,1;#C82909]" ..
        "hypertext[4,0.1;4.4,1;map_info;<big>Map Editor</big>]" ..
        "label[1.5,2;Select a game :]" ..
        "dropdown[1.5,2.5;7;game_selected;" .. games .. ";]" ..
        "button[0.7,4;4,1.5;new_map_btn;Create a map]" ..
        "button[5,4;4,1.5;all_maps_btn;View existing maps]"

    core.show_formspec(player:get_player_name(), "minigame_editor:homepage", form)
end

local function show_existing_maps(player)
    local player_name = player:get_player_name()
    local editor = minigame_editor[player_name]
    local game_name = editor.game_name
    if not game_name then return end

    local form = "size[10,7]" ..
        "box[2.5,0;5,1;#C82909]" ..
        "hypertext[3.5,0.1;4.4,1;map_info;<big>Current game " .. game_name .. " - Choose a map</big>]" ..
        "label[1.5,2;Select a map :]" ..
        "dropdown[1.5,2.5;7;map_selected;" .. table.concat(minigame.get_maps(game_name), ",") .. ";]" ..
        "button[2.8,4;4,1.5;edit_map_btn;Edit Map]"

    core.show_formspec(player_name, "minigame_editor:existing_maps", form)
end

local function show_main(player)
    local player_name = player:get_player_name()
    local editor = minigame_editor[player_name]
    local game_name = editor.game_name
    if not game_name then return end

    local map_name = editor.old_map_name
    local spawns = editor.data["spawns"] or nil
    local activated = editor.data["activated"] == true
    local spawn_count = editor.spawn_count
    local scroll_val = editor.scroll_value or 0
    local map = minigame[game_name].maps[map_name]

    local default_pos1, default_pos2 = nil, nil
    if map and map.pos1 and map.pos2 then
        default_pos1, default_pos2 = map.pos1, map.pos2
    end

    local pos1 = editor.data["pos1"] or default_pos1
    local pos2 = editor.data["pos2"] or default_pos2

    map_name = editor.new_map_name or map_name or ""

    local form = "size[10,12]" ..
        "box[2.5,0;5,1;#C82909]" ..
        "hypertext[3.5,0.1;4.4,1;map_info;<big>Editing a map for " .. game_name .. "</big>]" ..
        "label[3.2,1.2;Current editor : " .. player_name .. "]" ..

        "scrollbaroptions[max=550]" ..
        "scrollbar[9.6,2;0.4,10;vertical;map_edition;" .. scroll_val .. "]" ..
        "scroll_container[0,2.5;12,11.5;map_edition;vertical]" ..

        "checkbox[0,0;map_activated;Enable Map;" .. tostring(activated) .. "]" ..
        "field_close_on_enter[map_name;false]" ..
        "field[2.5,1;4,1;map_name;Map Name :;" .. core.formspec_escape(map_name) .. "]" ..
        "button[6.1,0.68;1,1;save_map_name_btn;Save]"

        local x = 0.5
        for i = 1, 2 do
            local pos = (i == 1) and pos1 or pos2

            form = form .. "label[" .. (x-0.3) .. ",1.8;Map pos" .. i .. ":]"

            for _, axe in ipairs({"x", "y", "z"}) do
                form = form .. "field_close_on_enter[pos" .. i .. "_" .. axe .. ";false]"

                if pos and pos[axe] then
                    form = form .. "field[" .. x .. ",3;1,1;pos" .. i .. "_" .. axe .. ";" .. axe .. ";" ..
                    core.formspec_escape(pos[axe]) .. "]"
                else
                    form = form .. "field[" .. x .. ",3;1,1;pos" .. i .. "_" .. axe .. ";" .. axe .. ";]"
                end

                x = x + 1
            end

            form = form .. "button[" .. (x-0.4) .. ",2.68;1,1;save_pos" .. i .. "_btn;Save]"

            x = x + 2
        end

        form = form .. "label[0.2,4;Spawns :]" ..
        "scrollbaroptions[min=1;max=20;smallstep=1]" ..
        "label[0.2,4.8;Count : " .. spawn_count .. "]" ..
        "scrollbar[0.2,5.2;7,0.5;horizontal;spawn_count;" .. spawn_count .. "]"

        local y = 7.5
        for i = 1, spawn_count do
            x = 2.5
            form = form .. "label[2.2," .. (y-1.2) ..";Spawn " .. i .. " :]"
            for _, axe in pairs({"x", "y", "z"}) do
                form = form .. "field_close_on_enter[spawn_" .. i .. "_" .. axe .. ";false]"
                if spawns and spawns[i] then
                    form = form .. "field[" .. x .. "," .. y .. ";1,1;spawn_" .. i .. "_" .. axe .. ";" .. axe .. ";" ..
                    spawns[i][axe] .. "]"
                else
                    form = form .. "field[" .. x .. "," .. y .. ";1,1;spawn_" .. i .. "_" .. axe .. ";" .. axe .. ";]"
                end

                x = x + 1
            end

            form = form .. "button[" .. (x-0.4) .. "," .. (y-0.32) .. ";1,1;save_spawn" .. i .. "_btn;Save]"
            form = form .. "button[" .. (x+0.5) .. "," .. (y-0.32) .. ";1,1;remove_spawn" .. i .. "_btn;X]"

            y = y + 2
        end

        form = form .. "button_exit[1.8," .. (y-0.5) .. ";6,1;custom_properties_btn;Change custom properties]" ..
        "button_exit[1.5," .. (y+0.5) .. ";3,1;save_map_btn;Save Map]" ..
        "button_exit[5," .. (y+0.5) .. ";3,1;cancel_btn;Cancel Edit]"

        form = form .. "scroll_container_end[]"

    core.show_formspec(player_name, "minigame_editor:main", form)
end

--[[
local function show_custom_properties(player)
    local player_name = player:get_player_name()
    local editor = minigame_editor[player_name]
    local game_name = editor.game_name
    if not game_name then return end

    local custom_props = minigame[game_name].def.custom_properties or {}
    local data = editor.data.custom_properties or {}

    local form = "size[10,12]" ..
        "box[2.5,0;5,1;#C82909]" ..
        "hypertext[3.5,0.1;4.4,1;map_info;<big>Editing a map for " .. game_name .. "</big>]" ..
        "label[3.2,1.2;Current editor : " .. player_name .. "]"

    local y = 3

    if custom_props then
        for prop_name, def in pairs(custom_props) do
            form = form .. "label[0.2," .. (y) .. ";" .. prop_name .. ":]"

            if type(def.fields) == "table" then
                local x = 0.3
                for field_name, ftype in pairs(def.fields) do
                    local name = prop_name .. "_" .. field_name
                    local current_val = data and data[prop_name] and data[prop_name][field_name] or ""

                    if ftype == "number" or ftype == "string" then
                        form = form .. "field[" .. x .. "," .. (y+1.2) ..
                            ";2,1;" .. name .. ";" .. field_name .. ";" ..
                            core.formspec_escape(tostring(current_val)) .. "]"

                        x = x + 2.5

                    elseif ftype == "pos" then
                        local pos = current_val or {x="", y="", z=""}
                        for _, axe in ipairs({"x","y","z"}) do
                            local fname = name .. "_" .. axe
                            form = form .. "field[" .. x .. "," .. (y+1.2) .. ";1,1;" .. fname .. ";" .. axe .. ";" ..
                            core.formspec_escape(tostring(pos[axe] or "")) .. "]"

                            x = x + 1
                        end

                    elseif type(ftype) == "table" then -- enum
                        local values = table.concat(ftype, ",")
                        local idx = 1
                        if current_val then
                            for i,v in ipairs(ftype) do
                                if v == current_val then idx = i break end
                            end
                        end

                        form = form .. "dropdown[" .. x .. "," .. (y+0.95) ..
                        ";3;" .. name .. ";" .. values .. ";" .. idx .. "]"

                        x = x + 3.5
                    end
                end
            end
            y = y + 2
        end
    end

    form = form .. "button_exit[1.5," .. y .. ";3,1;save_custom_btn;Save]" ..
    "button_exit[5," .. y .. ";3,1;cancel_btn;Cancel]"

    core.show_formspec(player_name, "minigame_editor:custom_properties", form)
end
]]

core.register_chatcommand("map_editor", {
    description = "Show the map editor",
    params = "c",
    privs = {map_editor=true},
    func = function(player_name, param)
        local player = core.get_player_by_name(player_name)
        if not player then return end

        if param == "c" then
            if minigame_editor[player_name] then
                minigame_editor[player_name] = nil
                return true, editor_prefix .. "Map edit cancelled!"
            else
                return false, editor_prefix .. "You are not editing a map!"
            end
        end

        if minigame_editor[player_name] then
            show_main(player)
            return true
        end

        if #minigame.get_all_games() ~= 0 then
            show_homepage(player)
        else
            return false, editor_prefix .. "Unable to find a game!"
        end
    end
})

core.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    if formname == "minigame_editor:homepage" then
        if fields.all_maps_btn then
            local game_name = fields.game_selected

            if #minigame.get_maps(game_name) == 0 then
                core.close_formspec(player_name, "minigame_editor:homepage")
                core.chat_send_player(player_name, editor_prefix ..
                "This game doesn't contain any maps. Choose the other option if you want to create a new one.")
                return false
            end

            minigame_editor[player_name] = {
                game_name = game_name,
                data = {}
            }

            show_existing_maps(player)

        elseif fields.new_map_btn then
            local game_name = fields.game_selected

            minigame_editor[player_name] = {
                game_name   = game_name,
                spawn_count = 1,
                data        = {activated   = true}
            }

            show_main(player)
        end
    elseif formname == "minigame_editor:existing_maps" then
        if fields.edit_map_btn then
            local game_name = minigame_editor[player_name].game_name
            local map_name = fields.map_selected
            local map  = minigame[game_name].maps[map_name]
            local spawns = minigame.get_spawns(map) or {}

            minigame_editor[player_name].old_map_name       = map_name
            minigame_editor[player_name].spawn_count        = #spawns
            minigame_editor[player_name].data["spawns"]     = spawns
            minigame_editor[player_name].data["activated"]  = minigame.map_enabled(map)

            minigame[game_name].maps[map_name].activated = false

            show_main(player)

        elseif fields.quit then
            minigame_editor[player_name] = nil
        end
    elseif formname == "minigame_editor:main" then
        --print(dump(fields))

        if not fields.quit then
            -- ===== KEEP AN EYE ON THE SCROLLBAR =====
            minigame_editor[player_name].scroll_value = core.explode_scrollbar_event(fields.map_edition).value
        end

        local scroll_event = core.explode_scrollbar_event(fields.spawn_count)
        for i = 1, scroll_event.value do
            local name = "spawn_" .. i
            local save_btn = "save_spawn" .. i .. "_btn"

            if (fields[save_btn] or fields.key_enter_field == name .. "_x"
            or fields.key_enter_field == name .. "_y" or fields.key_enter_field == name .. "_z")
            and fields[name .. "_x"] ~= "" and fields[name .. "_y"] ~= "" and fields[name .. "_z"] ~= "" then
                local spawn = core.string_to_pos(fields[name .. "_x"] .. "," ..
                fields[name .. "_y"] .. "," .. fields[name .. "_z"])

                minigame_editor[player_name].data["spawns"] = minigame_editor[player_name].data["spawns"] or {}

                if is_vector(spawn) then
                    minigame_editor[player_name].data["spawns"][i] = spawn

                    core.chat_send_player(player_name,
                        ("%sSpawn (%d) saved : %s"):format(editor_prefix, i, core.pos_to_string(spawn)))
                else
                    core.chat_send_player(player_name, editor_prefix .. "Invalid position!")
                end

            elseif fields["remove_spawn" .. i .. "_btn"] then
                local spawn = minigame_editor[player_name].data["spawns"]
                if spawn and spawn[i] then
                    minigame_editor[player_name].data["spawns"][i] = nil
                    show_main(player)
                end
            end
        end

        if fields.map_activated then
            if fields.map_activated == "true" then
                minigame_editor[player_name].data["activated"] = true
            else
                minigame_editor[player_name].data["activated"] = false
            end

        elseif fields.save_map_name_btn and fields.map_name ~= ""
        or fields.key_enter_field == "map_name" and fields.map_name ~= "" then
            -- ===== SAVE MAP NAME =====
            minigame_editor[player_name].new_map_name = fields.map_name

            core.chat_send_player(player_name,
            ("%sMap name saved : %s"):format(editor_prefix, minigame_editor[player_name].new_map_name))

        elseif fields.save_pos1_btn and fields.pos1_x ~= "" and fields.pos1_y ~= "" and fields.pos1_z ~= ""
        or fields.key_enter_field == "pos1_x" and fields.pos1_x ~= "" and fields.pos1_y ~= "" and fields.pos1_z ~= ""
        or fields.key_enter_field == "pos1_y" and fields.pos1_x ~= "" and fields.pos1_y ~= "" and fields.pos1_z ~= ""
        or fields.key_enter_field == "pos1_z" and fields.pos1_x ~= "" and fields.pos1_y ~= "" and fields.pos1_z ~= ""
        then
            -- ===== SAVE MAP POS1 =====
            local pos1 = core.string_to_pos(fields.pos1_x .. "," .. fields.pos1_y .. "," .. fields.pos1_z)
            if is_vector(pos1) then
                minigame_editor[player_name].data["pos1"] = pos1

                core.chat_send_player(player_name,
                ("%sMap pos1 saved : %s"):format(editor_prefix, core.pos_to_string(pos1)))
            else
                core.chat_send_player(player_name, editor_prefix .. "Invalid position!")
            end

        elseif fields.save_pos2_btn and fields.pos2_x ~= "" and fields.pos2_y ~= "" and fields.pos2_z ~= ""
        or fields.key_enter_field == "pos2_x" and fields.pos2_x ~= "" and fields.pos2_y ~= "" and fields.pos2_z ~= ""
        or fields.key_enter_field == "pos2_y" and fields.pos2_x ~= "" and fields.pos2_y ~= "" and fields.pos2_z ~= ""
        or fields.key_enter_field == "pos2_z" and fields.pos2_x ~= "" and fields.pos2_y ~= "" and fields.pos2_z ~= ""
        then
            -- ===== SAVE  MAP POS2 =====
            local pos2 = core.string_to_pos(fields.pos2_x .. "," .. fields.pos2_y .. "," .. fields.pos2_z)
            if is_vector(pos2) then
                minigame_editor[player_name].data["pos2"] = pos2

                core.chat_send_player(player_name,
                ("%sMap pos2 saved : %s"):format(editor_prefix, core.pos_to_string(pos2)))
            else
                core.chat_send_player(player_name, editor_prefix .. "Invalid position!")
            end

        elseif scroll_event.type == "CHG" then

            minigame_editor[player_name].spawn_count = scroll_event.value
            show_main(player)

        elseif fields.custom_properties_btn then

            core.chat_send_player(player_name, editor_prefix .. "Work in progress ...")
            --show_custom_properties(player)

        elseif fields.save_map_btn then
            -- ===== SAVE MAP =====
            local editor = minigame_editor[player_name]
            local game_name = editor.game_name
            local old_map_name = editor.old_map_name
            local new_map_name = editor.new_map_name or old_map_name

            local current_map_name = new_map_name
            local map  = minigame[game_name].maps[old_map_name]

            local default_pos1, default_pos2, default_spawns = nil
            if map then
                default_pos1, default_pos2, default_spawns = map.pos1, map.pos2, minigame.get_spawns(map)
            end

            local pos1 = editor.data["pos1"] or default_pos1
            local pos2 = editor.data["pos2"] or default_pos2
            local spawns = editor.data["spawns"] or default_spawns
            local spawn_count = editor.spawn_count

            if current_map_name == nil then
                core.chat_send_player(player_name,
                editor_prefix .. "The name of the map must be defined!")
                return false

            elseif not pos1 or not pos2 then
                core.chat_send_player(player_name,
                editor_prefix .. "The positions (1) and (2) of the map must both be defined")
                return false
            end

            if spawns then
                for i = 1, spawn_count do
                    if not spawns[i] then
                        core.chat_send_player(player_name,
                        ("%sSpawn (%d) is not defined!"):format(editor_prefix, i))

                        return false
                    end
                end
            else
                core.chat_send_player(player_name, editor_prefix .. "The spawns must be defined!")
                return false
            end

            -- ===== NEW DATA =====
            minigame.reload_maps()

            local map_data = {}

            -- Check if the map already exists and gets data
            if old_map_name ~= nil then
                map_data = table.copy(minigame[game_name].maps[old_map_name])

                -- Check if the name has changed
                if new_map_name ~= old_map_name then
                    minigame[game_name].maps[old_map_name] = nil
                end
            end

            for k, v in pairs(editor.data) do
                map_data[k] = v
            end

            minigame[game_name].maps[current_map_name] = map_data

            minigame.save_maps()
            -- ===== END OF NEW DATA =====

            if minigame[game_name].settings.map_regen == true then
                minigame.create_schematic(game_name, current_map_name)
            end

            minigame_editor[player_name] = nil

        elseif fields.cancel_btn then
            -- ===== MAP EDIT CANCELLED =====
            minigame_editor[player_name] = nil

            core.chat_send_player(player_name, editor_prefix .. "Map edit cancelled!")
        end
    end
end)

function is_vector(v)
    return type(v) == "table"
        and type(v.x) == "number"
        and type(v.y) == "number"
        and type(v.z) == "number"
end

core.register_on_leaveplayer(function(player)
    if minigame_editor[player:get_player_name()] then
        minigame_editor[player:get_player_name()] = nil
    end
end)