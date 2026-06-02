local sessions = {}

local FORM_HOME = "minigame_editor:home"
local FORM_MAPS = "minigame_editor:maps"
local FORM_EDIT = "minigame_editor:edit"
local FORM_CUSTOM = "minigame_editor:custom"
local FORM_DELETE = "minigame_editor:delete"

local PREFIX = core.colorize("#C82909", "[Map Editor]")
local AXES = {"x", "y", "z"}
local RUNTIME_FIELDS = {
    players = true,
    spectators = true,
    loading = true,
    running = true,
    timer = true,
    loading_timer = true,
}

core.register_privilege("map_editor", {
    description = "Allows the player to edit a map",
    give_to_singleplayer = true,
})

local function message(player_name, text)
    core.chat_send_player(player_name, PREFIX .. " " .. text)
end

local function trim(value)
    return tostring(value or ""):gsub("^%s*(.-)%s*$", "%1")
end

local function escape(value)
    return core.formspec_escape(tostring(value or ""))
end

local function deep_copy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, inner in pairs(value) do
        copy[key] = deep_copy(inner)
    end

    return copy
end

local function sorted_names(values)
    local names = ms_utils.copy_sequence(values)
    table.sort(names)
    return names
end

local function get_index(values, selected)
    local index = table.indexof(values, selected)
    if not index or index == -1 then
        return 1
    end

    return index
end

local function dropdown_values(values)
    local escaped = {}
    for _, value in ipairs(values) do
        table.insert(escaped, escape(value))
    end

    return table.concat(escaped, ",")
end

local function get_session(player_name)
    return sessions[player_name]
end

local function get_game(session)
    return session and minigame.get_game(session.game_name)
end

local function current_pos(player)
    return vector.round(player:get_pos())
end

local function copy_map_data(map)
    local data = {}

    for key, value in pairs(map or {}) do
        if not RUNTIME_FIELDS[key] then
            data[key] = deep_copy(value)
        end
    end

    if data.activated == nil then
        data.activated = true
    end

    data.spawns = data.spawns or {}

    return data
end

local function start_session(player_name, game_name, map_name)
    local map = map_name and minigame.get_map(game_name, map_name) or nil

    sessions[player_name] = {
        game_name = game_name,
        old_map_name = map_name,
        map_name = map_name or "",
        data = copy_map_data(map),
        selected_custom = nil,
    }

    if not map_name then
        sessions[player_name].data.activated = true
    end

    return sessions[player_name]
end

local function parse_number(value)
    if value == nil or value == "" then
        return nil
    end

    return tonumber(value)
end

local function parse_pos_fields(fields, prefix)
    local pos = {}

    for _, axis in ipairs(AXES) do
        local value = parse_number(fields[prefix .. "_" .. axis])
        if not value then
            return nil
        end

        pos[axis] = value
    end

    return pos
end

local function pos_field(prefix, axis, pos, x, y)
    local value = pos and pos[axis] or ""
    return ("field[%.1f,%.1f;1.15,0.8;%s_%s;%s;%s]"):format(
        x, y, prefix, axis, axis, escape(value))
end

local function add_pos_fields(form, prefix, pos, x, y)
    for _, axis in ipairs(AXES) do
        form[#form + 1] = pos_field(prefix, axis, pos, x, y)
        x = x + 1.2
    end
end

local function sync_main_fields(session, fields)
    if fields.map_name ~= nil then
        session.map_name = trim(fields.map_name)
    end

    if fields.map_activated ~= nil then
        session.data.activated = fields.map_activated == "true"
    end

    local pos1 = parse_pos_fields(fields, "pos1")
    if pos1 then
        session.data.pos1 = pos1
    end

    local pos2 = parse_pos_fields(fields, "pos2")
    if pos2 then
        session.data.pos2 = pos2
    end

    session.data.spawns = session.data.spawns or {}

    for field_name, _ in pairs(fields) do
        local index = field_name:match("^spawn_(%d+)_x$")
        if index then
            index = tonumber(index)
            local spawn = parse_pos_fields(fields, "spawn_" .. index)
            if spawn then
                session.data.spawns[index] = spawn
            end
        end
    end
end

local function validate_session(session)
    if not session then
        return nil, "No editor session is active."
    end

    if session.map_name == "" then
        return nil, "Map name is required."
    end

    if not ms_utils.is_vector(session.data.pos1) or not ms_utils.is_vector(session.data.pos2) then
        return nil, "Map pos1 and pos2 must be defined."
    end

    if not session.data.spawns or #session.data.spawns == 0 then
        return nil, "At least one spawn is required."
    end

    for index, spawn in ipairs(session.data.spawns) do
        if not ms_utils.is_vector(spawn) then
            return nil, ("Spawn %d is invalid."):format(index)
        end
    end

    local existing = minigame.get_map(session.game_name, session.map_name)
    if existing and session.map_name ~= session.old_map_name then
        return nil, "Another map already uses this name."
    end

    local data = deep_copy(session.data)
    data.activated = data.activated ~= false
    data.spawns = ms_utils.copy_sequence(data.spawns)

    if vector.sort then
        data.pos1, data.pos2 = vector.sort(data.pos1, data.pos2)
    end

    return data
end

local function save_session(player_name)
    local session = get_session(player_name)
    local data, err = validate_session(session)
    if not data then
        message(player_name, err)
        return false
    end

    local game = minigame.get_game(session.game_name)
    if not game then
        message(player_name, "Game no longer exists.")
        sessions[player_name] = nil
        return false
    end

    if session.old_map_name and session.old_map_name ~= session.map_name then
        game.maps[session.old_map_name] = nil
    end

    game.maps[session.map_name] = data
    minigame.save_maps()

    if game.settings.map_regen then
        minigame.create_schematic(session.game_name, session.map_name)
    end

    session.old_map_name = session.map_name
    session.data = copy_map_data(data)

    message(player_name, ("Map %s saved."):format(session.map_name))
    return true
end

local function show_home(player)
    local player_name = player:get_player_name()
    local games = sorted_names(minigame.get_all_games())

    if #games == 0 then
        core.show_formspec(player_name, FORM_HOME,
            "size[8,4]label[0.5,0.7;No minigame is registered.]button_exit[2.5,2.5;3,1;close;Close]")
        return
    end

    local form = {
        "size[10,6]",
        "box[0,0;10,1;#C82909]",
        "hypertext[4,0.2;4.4,1;;<big>Map Editor</big>]" ..
        "label[0.9,1.55;Game :]",
        ("dropdown[2.1,1.45;7,0.8;game_name;%s;1]"):format(dropdown_values(games)),
        "button[1,3.1;2.5,1;new_map;New map]",
        "button[3.75,3.1;2.5,1;edit_maps;Edit maps]",
        "button[6.5,3.1;2.5,1;reload_maps;Reload maps]",
        "button_exit[3.75,4.65;2.5,0.8;close;Close]",
    }

    core.show_formspec(player_name, FORM_HOME, table.concat(form))
end

local function show_maps(player)
    local player_name = player:get_player_name()
    local session = get_session(player_name)
    if not session then
        show_home(player)
        return
    end

    local maps = sorted_names(minigame.get_maps(session.game_name))
    local form = {
        "size[10,6]",
        "box[0,0;10,1;#C82909]",
        ("hypertext[4,0.2;4.4,1;;<big>Maps for %s</big>]"):format(escape(session.game_name)),
        "button[0.5,5;2,0.8;back;Back]",
    }

    if #maps == 0 then
        form[#form + 1] = "label[0.8,2;No map exists for this game.]"
        form[#form + 1] = "button[3.7,3.2;2.8,1;new_map;Create first map]"
    else
        form[#form + 1] = "label[0.8,1.7;Map]"
        form[#form + 1] = ("dropdown[2.1,1.45;7,0.8;map_name;%s;1]"):format(dropdown_values(maps))
        form[#form + 1] = "button[1.2,3.2;2.3,1;edit_map;Edit]"
        form[#form + 1] = "button[3.85,3.2;2.3,1;duplicate_map;Duplicate]"
        form[#form + 1] = "button[6.5,3.2;2.3,1;delete_map;Delete]"
    end

    core.show_formspec(player_name, FORM_MAPS, table.concat(form))
end

local function show_edit(player)
    local player_name = player:get_player_name()
    local session = get_session(player_name)
    if not session then
        show_home(player)
        return
    end

    local data = session.data
    local spawns = data.spawns or {}
    local form = {
        "size[14,11]",
        "box[0,0;14,1;#C82909]",
        ("hypertext[0.35,0.2;4.4,1;;<big>Editing %s</big>]"):format(escape(session.game_name)),
        "label[0.5,1.35;Map name]",
        ("field[2.1,1.5;4.8,0.8;map_name;;%s]"):format(escape(session.map_name)),
        ("checkbox[7.3,1.2;map_activated;Enabled;%s]"):format(tostring(data.activated ~= false)),
        "button[10.4,1.05;1.4,0.8;save;Save]",
        "button[12,1.05;1.4,0.8;close;Done]",
        "label[0.5,2.35;Bounds]",
        "label[1.2,3.05;pos1]",
        "label[1.2,4.05;pos2]",
    }

    add_pos_fields(form, "pos1", data.pos1, 2.1, 3.25)
    add_pos_fields(form, "pos2", data.pos2, 2.1, 4.25)

    form[#form + 1] = "button[5.9,3.1;2,0.8;capture_pos1;Use current]"
    form[#form + 1] = "button[5.9,4.1;2,0.8;capture_pos2;Use current]"
    form[#form + 1] = "button[8.1,3.1;1.6,0.8;teleport_pos1;Go]"
    form[#form + 1] = "button[8.1,4.1;1.6,0.8;teleport_pos2;Go]"
    form[#form + 1] = ("label[10.5,2.55;Spawns: %d]"):format(#spawns)
    form[#form + 1] = "button[10.5,3;3,0.8;add_spawn_here;Add current spawn]"
    form[#form + 1] = "button[10.5,4;3,0.8;custom_props;Custom properties]"
    form[#form + 1] = "scrollbaroptions[min=0;max=1000]"
    form[#form + 1] = "scrollbar[13.45,5.1;0.35,5.1;vertical;spawn_scroll;0]"
    form[#form + 1] = "scroll_container[0,6.5;14.5,5.7;spawn_scroll;vertical]"

    local y = 0.5
    for index, spawn in ipairs(spawns) do
        form[#form + 1] = ("hypertext[2.4,%.2f;2,1;;<style color=yellow><big>#%d</big></style>]"):format(y, index)
        add_pos_fields(form, "spawn_" .. index, spawn, 3.15, y)
        form[#form + 1] = ("button[6.95,%.2f;1.65,0.8;spawn_use_%d;Current]"):format(y - 0.3, index)
        form[#form + 1] = ("button[8.75,%.2f;1.15,0.8;spawn_tp_%d;Go]"):format(y - 0.3, index)
        form[#form + 1] = ("button[10.05,%.2f;1.25,0.8;spawn_remove_%d;Remove]"):format(y - 0.3, index)
        y = y + 1.05
    end

    if #spawns == 0 then
        form[#form + 1] = "label[4,0.5;No spawn yet. Use Add current spawn.]"
    end

    form[#form + 1] = "scroll_container_end[]"
    form[#form + 1] = "button[0.5,10.35;2,0.8;back_home;Home]"
    form[#form + 1] = "button[2.7,10.35;2.2,0.8;back_maps;Map list]"
    form[#form + 1] = "button[10.7,10.35;3,0.8;cancel;Cancel session]"

    core.show_formspec(player_name, FORM_EDIT, table.concat(form))
end

local function custom_props_for(session)
    local game = get_game(session)
    return game and game.custom_properties or {}
end

local function custom_prop_names(session)
    local names = {}

    for name, _ in pairs(custom_props_for(session)) do
        table.insert(names, name)
    end

    table.sort(names)
    return names
end

local function default_custom_value(field_type, player)
    if field_type == "pos" then
        return current_pos(player)
    elseif field_type == "number" then
        return 1
    elseif type(field_type) == "table" then
        return tonumber(field_type[1]) or field_type[1] or ""
    end

    return ""
end

local function custom_field_name(index, field_name, axis)
    if axis then
        return ("custom_%d_%s_%s"):format(index, field_name, axis)
    end

    return ("custom_%d_%s"):format(index, field_name)
end

local function get_custom_field_names(fields)
    local names = {}

    for field_name, _ in pairs(fields or {}) do
        table.insert(names, field_name)
    end

    table.sort(names)
    return names
end

local function sync_custom_fields(session, fields)
    local prop_name = session.selected_custom
    if not prop_name then
        return
    end

    local prop_def = custom_props_for(session)[prop_name]
    if not prop_def or type(prop_def.fields) ~= "table" then
        return
    end

    local records = session.data[prop_name] or {}

    for index, record in ipairs(records) do
        for _, field_name in ipairs(get_custom_field_names(prop_def.fields)) do
            local field_type = prop_def.fields[field_name]

            if field_type == "pos" then
                local prefix = custom_field_name(index, field_name)
                local pos = parse_pos_fields(fields, prefix)
                if pos then
                    record[field_name] = pos
                end
            elseif field_type == "number" then
                local number = parse_number(fields[custom_field_name(index, field_name)])
                if number ~= nil then
                    record[field_name] = number
                end
            elseif type(field_type) == "table" then
                local value = fields[custom_field_name(index, field_name)]
                if value ~= nil then
                    record[field_name] = tonumber(value) or value
                end
            else
                local value = fields[custom_field_name(index, field_name)]
                if value ~= nil then
                    record[field_name] = value
                end
            end
        end
    end
end

local function add_custom_record(session, player)
    local prop_name = session.selected_custom
    local prop_def = custom_props_for(session)[prop_name]
    if not prop_def or type(prop_def.fields) ~= "table" then
        return
    end

    session.data[prop_name] = session.data[prop_name] or {}
    local record = {}

    for _, field_name in ipairs(get_custom_field_names(prop_def.fields)) do
        local field_type = prop_def.fields[field_name]
        record[field_name] = default_custom_value(field_type, player)
    end

    table.insert(session.data[prop_name], record)
end

local function show_custom(player)
    local player_name = player:get_player_name()
    local session = get_session(player_name)
    if not session then
        show_home(player)
        return
    end

    local prop_names = custom_prop_names(session)
    if #prop_names == 0 then
        message(player_name, "This game has no custom properties.")
        --show_edit(player)
        return
    end

    session.selected_custom = session.selected_custom or prop_names[1]
    local prop_name = session.selected_custom
    local prop_def = custom_props_for(session)[prop_name]
    local records = session.data[prop_name] or {}

    local form = {
        "size[14,11]",
        "box[0,0;14,1;#C82909]",
        "hypertext[0.35,0.2;4.4,1;;<big>Custom properties</big>]",
        "label[0.5,1.7;Property]",
        ("dropdown[2.1,1.5;4.3,0.8;prop_name;%s;%d]"):format(
            dropdown_values(prop_names), get_index(prop_names, prop_name)),
        "button[6.65,1.4;1.7,0.8;select_prop;Open]",
        "button[8.55,1.4;2.1,0.8;add_record;Add entry]",
        "button[10.85,1.4;1.6,0.8;save;Save]",
        "button[12.55,1.4;1.1,0.8;back;Back]",
        ("label[0.25,10.5;%s entries: %d]"):format(escape(prop_name), #records),
        "scrollbaroptions[min=0;max=1500]",
        "scrollbar[13.45,3.5;0.35,7.2;vertical;custom_scroll;0]",
        "scroll_container[0,4.5;13.4,7.3;custom_scroll;vertical]",
    }

    local y = 0.2
    local fields = prop_def and prop_def.fields or {}

    for index, record in ipairs(records) do
        --form[#form + 1] = ("box[0.35,%.2f;12.4,1.6;#333333]"):format(y - 0.05)
        form[#form + 1] = ("hypertext[0.55,%.2f;2,1;;<style color=yellow><big>#%d</big></style>]"):format(
            y + 0.45, index)

        local x = 1.2
        for _, field_name in ipairs(get_custom_field_names(fields)) do
            local field_type = fields[field_name]
            local value = record[field_name]

            if field_type == "pos" then
                --form[#form + 1] = ("label[%.2f,%.2f;%s]"):format(x, y, escape(field_name))
                add_pos_fields(form, custom_field_name(index, field_name), value, x, y + 0.7)
                x = x + 3.8
            elseif type(field_type) == "table" then
                form[#form + 1] = ("label[%.2f,%.2f;%s]"):format(x, y, escape(field_name))
                form[#form + 1] = ("dropdown[%.2f,%.2f;1.5,0.8;%s;%s;%d]"):format(
                    x, y + 0.35, custom_field_name(index, field_name),
                    dropdown_values(field_type), get_index(field_type, tostring(value)))
                x = x + 2
            else
                form[#form + 1] = ("field[%.2f,%.2f;2.1,0.8;%s;%s;%s]"):format(
                    x, y + 0.35, custom_field_name(index, field_name),
                    escape(field_name), escape(value))
                x = x + 2.2
            end
        end

        form[#form + 1] = ("button[11.2,%.2f;1.4,0.8;custom_remove_%d;Remove]"):format(y + 0.35, index)
        y = y + 1.9
    end

    if #records == 0 then
        form[#form + 1] = "label[0.5,0.6;No entry yet. Use Add entry.]"
    end

    form[#form + 1] = "scroll_container_end[]"

    core.show_formspec(player_name, FORM_CUSTOM, table.concat(form))
end

local function delete_map(player_name, game_name, map_name)
    local state = minigame.get_map_state(game_name, map_name)
    if state == "running" or state == "loading" then
        message(player_name, "You cannot delete a running or loading map.")
        return false
    end

    local game = minigame.get_game(game_name)
    if not game or not game.maps[map_name] then
        message(player_name, "Map no longer exists.")
        return false
    end

    game.maps[map_name] = nil
    minigame.save_maps()
    message(player_name, ("Map %s deleted."):format(map_name))
    return true
end

core.register_chatcommand("map_editor", {
    description = "Show the map editor",
    params = "c",
    privs = {map_editor = true},
    func = function(player_name, param)
        local player = core.get_player_by_name(player_name)
        if not player then return end

        if param == "c" then
            if sessions[player_name] then
                sessions[player_name] = nil
                return true, PREFIX .. " " .. "Map edit cancelled."
            end

            return false, PREFIX .. " " .. "You are not editing a map."
        end

        if sessions[player_name] then
            show_edit(player)
            return true
        end

        show_home(player)
        return true
    end
})

core.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()

    if fields.quit then
        return
    end

    if formname == FORM_HOME then
        local game_name = fields.game_name
        if not game_name or game_name == "" then
            return
        end

        if fields.new_map then
            start_session(player_name, game_name)
            show_edit(player)
        elseif fields.edit_maps then
            start_session(player_name, game_name)
            show_maps(player)
        elseif fields.reload_maps then
            minigame.reload_maps()
            message(player_name, "Maps reloaded.")
            show_home(player)
        end

    elseif formname == FORM_MAPS then
        local session = get_session(player_name)
        if not session then
            show_home(player)
            return
        end

        if fields.back then
            sessions[player_name] = nil
            show_home(player)
        elseif fields.new_map then
            start_session(player_name, session.game_name)
            show_edit(player)
        elseif fields.edit_map and fields.map_name then
            start_session(player_name, session.game_name, fields.map_name)
            show_edit(player)
        elseif fields.duplicate_map and fields.map_name then
            local new_session = start_session(player_name, session.game_name, fields.map_name)
            new_session.old_map_name = nil
            new_session.map_name = fields.map_name .. " Copy"
            show_edit(player)
        elseif fields.delete_map and fields.map_name then
            sessions[player_name].pending_delete = fields.map_name
            local form = ("size[8,4]label[0.5,1;Delete map %s?]"):format(escape(fields.map_name)) ..
                "button[1.2,2.4;2,0.8;confirm;Delete]" ..
                "button[4.6,2.4;2,0.8;cancel;Cancel]"

            core.show_formspec(player_name, FORM_DELETE, form)
        end

    elseif formname == FORM_DELETE then
        local session = get_session(player_name)
        if not session then
            show_home(player)
            return
        end

        if fields.confirm and session.pending_delete then
            delete_map(player_name, session.game_name, session.pending_delete)
            session.pending_delete = nil
        end

        show_maps(player)

    elseif formname == FORM_EDIT then
        local session = get_session(player_name)
        if not session then
            show_home(player)
            return
        end

        sync_main_fields(session, fields)

        if fields.capture_pos1 then
            session.data.pos1 = current_pos(player)
        elseif fields.capture_pos2 then
            session.data.pos2 = current_pos(player)
        elseif fields.teleport_pos1 and ms_utils.is_vector(session.data.pos1) then
            player:set_pos(session.data.pos1)
        elseif fields.teleport_pos2 and ms_utils.is_vector(session.data.pos2) then
            player:set_pos(session.data.pos2)
        elseif fields.add_spawn_here then
            session.data.spawns = session.data.spawns or {}
            table.insert(session.data.spawns, current_pos(player))
        elseif fields.custom_props then
            show_custom(player)
            return
        elseif fields.save then
            save_session(player_name)
        elseif fields.close then
            if save_session(player_name) then
                sessions[player_name] = nil
                show_home(player)
            else
                show_edit(player)
            end
            return
        elseif fields.back_home then
            show_home(player)
            return
        elseif fields.back_maps then
            show_maps(player)
            return
        elseif fields.cancel then
            sessions[player_name] = nil
            message(player_name, "Map edit cancelled.")
            show_home(player)
            return
        else
            for index, spawn in ipairs(session.data.spawns or {}) do
                if fields["spawn_use_" .. index] then
                    session.data.spawns[index] = current_pos(player)
                    break
                elseif fields["spawn_tp_" .. index] and ms_utils.is_vector(spawn) then
                    player:set_pos(spawn)
                    break
                elseif fields["spawn_remove_" .. index] then
                    table.remove(session.data.spawns, index)
                    break
                end
            end
        end

        show_edit(player)

    elseif formname == FORM_CUSTOM then
        local session = get_session(player_name)
        if not session then
            show_home(player)
            return
        end

        sync_custom_fields(session, fields)

        if fields.prop_name and (fields.select_prop or fields.prop_name ~= session.selected_custom) then
            session.selected_custom = fields.prop_name
        elseif fields.add_record then
            add_custom_record(session, player)
        elseif fields.save then
            save_session(player_name)
        elseif fields.back then
            show_edit(player)
            return
        else
            local records = session.selected_custom and session.data[session.selected_custom] or {}
            for index, _ in ipairs(records or {}) do
                if fields["custom_remove_" .. index] then
                    table.remove(records, index)
                    break
                end
            end
        end

        show_custom(player)
    end
end)

core.register_on_leaveplayer(function(player)
    sessions[player:get_player_name()] = nil
end)