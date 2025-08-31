minigame = {} -- Global table

-- Local variables
local S = core.get_translator(core.get_current_modname())
local minigame_path = core.get_worldpath() .. "/minigames"
local data_path = minigame_path .. "/maps.json"

local minigame_prefix = core.colorize("#D9D529", "[Minigame] ")

local player_index = {}
local active_games = {}

local function bool_or(value, default)
    if value ~= nil then
        return value
    end

    return default
end

-- Configuration
minigame.RESPAWN_ALLOWED    = bool_or(core.settings:get_bool("minigame_respawn_allowed"), false)
minigame.MIN_PLAYERS        = core.settings:get("minigame_min_players") or 2
minigame.END_MATCH          = bool_or(core.settings:get_bool("minigame_end_match"), true)
minigame.LOAD_TIME          = core.settings:get("minigame_load_time") or 10
minigame.MAP_REGEN          = bool_or(core.settings:get_bool("minigame_map_regen"), true)
minigame.MAP_TIMER          = core.settings:get("minigame_map_timer") or 600
minigame.HIDE_NAMETAGS      = bool_or(core.settings:get_bool("minigame_hide_nametags"), true)

function minigame.register(name, def)
    if minigame[name] then
        error("The minigame \"" .. name .. "\" is already registered.")
    end

    minigame[name] = {
        def = def,
        maps = {},
        settings = {
            respawn_allowed     = bool_or(def.respawn_allowed, minigame.RESPAWN_ALLOWED),
            max_players         = def.max_players or nil,
            min_players         = def.min_players or minigame.MIN_PLAYERS,
            end_match           = bool_or(def.end_match, minigame.END_MATCH),
            load_time           = def.load_time or minigame.LOAD_TIME,
            map_regen           = bool_or(def.map_regen, minigame.MAP_REGEN),
            map_timer           = def.map_timer or minigame.MAP_TIMER,
        },
        custom_properties = def.custom_properties or {},
    }

    core.log("action", "[Minigame] Game " .. name .. " registered!")
end


--
--- MAIN FUNCTIONS
--


function minigame.load_map(game_name, map_name, timer)
    core.log("action", ("[Minigame] Loading the map %s ..."):format(map_name))

    local game, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
    local map_info = minigame.get_map_information(game, map)
    local min_players = map_info.min_players

    active_games[game_name] = active_games[game_name] or {active_maps = {}}

    core.emerge_area(map.pos1, map.pos2)

    map.loading = true
    map.loading_timer = timer

    local function load()
        if #map.players < min_players then
            if game.def.on_unload then
                game.def.on_unload(map_name)
            end

            map.loading = false

            active_games[game_name].active_maps[map_name]:cancel()
            active_games[game_name].active_maps[map_name] = nil

            return

        elseif map.loading_timer <= 0 then
            map.loading = false

            minigame.start_game(game_name, map_name)

            return
        end

        if game.def.on_load then game.def.on_load(map_name, map.loading_timer) end

        map.loading_timer = map.loading_timer - 1

        active_games[game_name].active_maps[map_name] = core.after(1, load)
    end

    load()
end

function minigame.start_game(game_name, map_name)
    core.log("action", ("[Minigame] Launching %s on the map %s ..."):format(game_name, map_name))

    local game, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
    local map_info = minigame.get_map_information(game, map)
    local default_timer = map_info.map_timer
    local map_regen = map_info.map_regen
    local end_match = map_info.end_match

    if map_regen then
        minigame.clear_dropped_items(map)
        minigame.place_schematic(game_name, map_name)
    end

    if game.def.on_start then game.def.on_start(map_name) end

    active_games[game_name] = active_games[game_name] or {active_maps = {}}

    map.running = true
    map.timer = default_timer

    local function tick()
        if map.timer <= 0 or #map.players == 0 then

            minigame.end_game(game_name, map_name, "Time's up!", {})

            return

        elseif end_match and #map.players == 1 then -- TODO : Adapter pour des jeux en équipe
            local winners = {}
            for _, player in ipairs(minigame.get_players(map)) do
                table.insert(winners, player:get_player_name())
            end

            minigame.end_game(game_name, map_name, "winner", table.concat(winners, ","))

            return
        end

        minigame.check_and_teleport_players(map)

        if game.def.on_tick then game.def.on_tick(map_name, map.timer) end

        map.timer = map.timer - 1

        active_games[game_name].active_maps[map_name] = core.after(1, tick)
    end

    tick()
end

function minigame.end_game(game_name, map_name, reason, winners)
    core.log("action", ("[Minigame] Ending %s on the map %s ... Reason : %s"):format(game_name, map_name, reason))

    local game, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
    local map_info = minigame.get_map_information(game, map)
    local map_regen = map_info.map_regen
    local timer = map_info.map_timer
    local loading_timer = map_info.load_time

    if game.def.on_end then game.def.on_end(map_name, reason, winners) end

    for _, player in ipairs(minigame.get_players(map)) do minigame.reset_player(player) end
    for _, spectator in ipairs(minigame.get_spectators(map)) do minigame.reset_player(spectator) end

    if map_regen then
        minigame.clear_dropped_items(map)
        minigame.place_schematic(game_name, map_name)
    end

    map.players = {}
    map.spectators = {}
    map.running = false
    map.timer = timer
    map.loading_timer = loading_timer

    if active_games[game_name] and active_games[game_name].active_maps[map_name] then
        active_games[game_name].active_maps[map_name]:cancel()
        active_games[game_name].active_maps[map_name] = nil
    end
end

function minigame.attempt_join(player, game, map)
    local entry = minigame.get_player_entry(player)
    local player_name = player:get_player_name()

    if entry and entry.game and entry.map then
        core.chat_send_player(player_name, core.colorize("#F4320B", S("You are already in game!")))
        return false
    end

    if not minigame.map_enabled(map) then
        core.chat_send_player(player_name, core.colorize("#F4320B", S("This map is disabled!")))
        return false
    end

    -- Initialize tables
    map.players     = map.players or {}
    map.running     = map.running or false

    local max_players =  minigame.get_map_information(game, map).max_players
    if map.running or #map.players >= max_players then
        core.chat_send_player(player_name, core.colorize("#F4320B", S("The map is already full or running!")))
        return false
    end

    return true
end

function minigame.join_game(player, game_name, map_name)
    local player_name = player:get_player_name()
    local game = minigame[game_name]
    if not game then
        core.chat_send_player(player_name, S("Unable to find the game : @1", game_name))
        return
    end

    local map = game.maps[map_name]
    if not map then
        core.chat_send_player(player_name, S("Unable to find the map : @1", map_name))
        return
    end

    local can_join = minigame.attempt_join(player, game, map)
    if not can_join then return end

    table.insert(map.players, player)

    player_index[player:get_player_name()] = {game = game_name, map  = map_name}

    local map_info = minigame.get_map_information(game, map)
    local min_players = map_info.min_players
    local loading = map_info.loading
    local load_time = map_info.load_time
    local max_hp = core.PLAYER_MAX_HP_DEFAULT

    if player:get_hp() ~= max_hp then player:set_hp(max_hp) end

    minigame.clear_inventory(player)

    if minigame.HIDE_NAMETAGS then
        player:set_nametag_attributes({text = " ", color = {a=0, r=0, g=0, b=0}})
    end

    if game.def.on_join then game.def.on_join(player, map_name) end

    minigame.chat_send_all(map, core.colorize("grey", ">>> ") .. S("@1 joined the game.", player_name))

    core.log("action", "[Minigame] " .. player_name .. " joined the map \"" .. map_name .. "\"")

    if #map.players == min_players and not loading then
        minigame.load_map(game_name, map_name, load_time)
    end
end

function minigame.leave_game(player)
    local entry = minigame.get_player_entry(player)
    local player_name = player:get_player_name()

    if not entry  then
        core.chat_send_player(player_name, core.colorize("#F4320B", S("You are not in a game!")))
        return
    end

    local game, map = minigame.get_gamedef_and_mapdef(entry.game, entry.map)
    local loading = minigame.get_map_information(game, map).loading

    if loading then
        core.chat_send_player(player_name,
        core.colorize("#F4320B", S("You are not allowed to leave the map while it's loading!")))

        return
    end

    minigame.chat_send_all(map, core.colorize("grey", "<<< ").. S("@1 left the game.", player_name))

    if minigame.is_spectating(player) then
        for i, s in ipairs(minigame.get_spectators(map)) do
            if s == player then
                minigame.reset_player(player)

                table.remove(map.spectators, i)

                return
            end
        end
    else
        for i, p in ipairs(minigame.get_players(map)) do
            if p == player then
                if game.def.on_leave then game.def.on_leave(player_name, entry.map) end

                minigame.reset_player(player)

                table.remove(map.players, i)

                return
            end
        end
    end
end


--
--- RELATED FUNCTIONS
--


function minigame.get_players(map)
    local players = {}
    if not map.players then return players end

    for _, player in ipairs(map.players) do
        table.insert(players, player)
    end

    return players
end

function minigame.get_spectators(map)
    local spectators = {}
    if not map.spectators then return spectators end

    for _, spectator in ipairs(map.spectators) do
        table.insert(spectators, spectator)
    end

    return spectators
end

function minigame.get_all_players()
    local players = {}
    for _, game in pairs(minigame) do
        if type(game) == "table" and game.maps then
            for _, map in pairs(game.maps) do
                for _, player in ipairs(minigame.get_players(map)) do
                    table.insert(players, player)
                end
            end
        end
    end

    return players
end

function minigame.get_all_spectators()
    local spectators = {}
    for _, game in pairs(minigame) do
        if type(game) == "table" and game.maps then
            for _, map in pairs(game.maps) do
                for _, spectator in ipairs(minigame.get_spectators(map)) do
                    table.insert(spectators, spectator)
                end
            end
        end
    end

    return spectators
end

function minigame.chat_send_players(map, message)
    local list = {}
    for _, player in ipairs(minigame.get_players(map)) do
        table.insert(list, player:get_player_name())
    end

    for _, player_name in pairs(list) do
        core.chat_send_player(player_name, message)
    end
end

function minigame.chat_send_spectators(map, message)
    local list = {}
    for _, spectator in ipairs(minigame.get_spectators(map)) do
        table.insert(list, spectator:get_player_name())
    end

    for _, player_name in pairs(list) do
        core.chat_send_player(player_name, message)
    end
end

function minigame.chat_send_all(map, message)
    local list = {}
    for _, player in ipairs(minigame.get_players(map)) do
        table.insert(list, player:get_player_name())
    end

    for _, spectator in ipairs(minigame.get_spectators(map)) do
        table.insert(list, spectator:get_player_name())
    end

    for _, player_name in pairs(list) do
        core.chat_send_player(player_name, message)
    end
end

function minigame.get_all_games()
    local games = {}
    for game_name, game in pairs(minigame) do
        if type(game) == "table" and game.maps then
            table.insert(games, game_name)
        end
    end

    return games
end

function minigame.get_maps(game_name)
    local maps = {}
    if not minigame[game_name] then return maps end

    for map_name, _ in pairs(minigame[game_name].maps) do
        table.insert(maps, map_name)
    end

    return maps
end

function minigame.get_gamedef_and_mapdef(game_name, map_name)
    local gamedef = minigame[game_name]
    if not gamedef then return nil end

    local mapdef = gamedef.maps[map_name]
    if not mapdef then return gamedef, nil end

    return gamedef, mapdef
end

function minigame.get_spawns(map)
    local spawns = {}
    for _, spawn in ipairs(map.spawns) do
        table.insert(spawns, spawn)
    end

    return spawns
end

function minigame.get_player_in_map(map, player)
    for _, v in ipairs(minigame.get_players(map)) do
        if v == player then
            return true
        end
    end

    return false
end

function minigame.get_spectator_in_map(map, player)
    for _, v in ipairs(minigame.get_spectators(map)) do
        if v == player then
            return true
        end
    end

    return false
end

function minigame.get_player_entry(player)
    local entry = player_index[player:get_player_name()]
    if not entry then return nil end

    return {
        game = entry.game,
        map = entry.map
    }
end

function minigame.get_map_information(game, map)
    return {
        respawn_allowed = game.settings.respawn_allowed,
        max_players     = game.settings.max_players or map.spawns and #map.spawns or 0,
        min_players     = game.settings.min_players,
        end_match       = game.settings.end_match,
        load_time       = game.settings.load_time,
        map_regen       = game.settings.map_regen,
        map_timer       = game.settings.map_timer,
        loading         = map.loading or false,
        running         = map.running or false,
    }
end

function minigame.clear_inventory(player)
    local inv = player:get_inventory()
    inv:set_list("main", {})
    inv:set_list("craft", {})
end

function minigame.drop_inventory(player)
    local list = {}
    local inv = player:get_inventory()

    for _, main in pairs(inv:get_list("main")) do table.insert(list, main) end
    for _, craft in pairs(inv:get_list("craft")) do table.insert(list, craft) end

    for _, itemstack in pairs(list) do
        local pos = {
            x = player:get_pos().x + math.random(-1, 1),
            y = player:get_pos().y + 1,
            z = player:get_pos().z + math.random(-1, 1)
        }

        core.item_drop(itemstack, player, pos)
    end

    minigame.clear_inventory(player)
end

function minigame.clear_dropped_items(map)
    local pos1, pos2 = map.pos1, map.pos2

    local pos =  {
        x = (pos1.x + pos2.x) / 2,
        y = (pos1.y + pos2.y) / 2,
        z = (pos1.z + pos2.z) / 2
    }

    local radius = math.sqrt(
        (pos1.x - pos2.x)^2 +
        (pos1.y - pos2.y)^2 +
        (pos1.z - pos2.z)^2
    ) / 2

    for _, obj in pairs(core.get_objects_inside_radius(pos, radius)) do
        local entity = obj:get_luaentity()
        if entity and entity.name == "__builtin:item" then
            obj:remove()
        end
    end
end

function minigame.add_spectator(player, game_name, map_name)
    local player_meta = player:get_meta()
    local player_name = player:get_player_name()
    local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)

    local pos = vector.offset(map.spawns[1], 0, 2, 0)
    player:set_pos(pos)

    player:set_properties({
        pointable = false,
        visual_size = {x = 0, y = 0},
        is_visible = false,
        makes_footstep_sound = false,
        show_on_minimap = false
    })

    if not core.is_creative_enabled(player_name) then
        core.change_player_privs(player_name, {interact = false, fly = true, fast = true})
    end

    if minigame.HIDE_NAMETAGS then
        player:set_nametag_attributes({text = " ", color = {a=0, r=0, g=0, b=0}})
    end

    player_meta:set_string("is_spectator", "true")

    map.spectators  = map.spectators or {}

    table.insert(map.spectators, player)

    player_index[player:get_player_name()] = {game = game_name, map  = map_name}

    minigame.chat_send_all(map, core.colorize("grey", S("[Spectator] @1 is now spectating the map.", player_name)))

    local spectators = {}
    for _, spectator in ipairs(minigame.get_spectators(map)) do
        table.insert(spectators, spectator:get_player_name())
    end

    core.chat_send_player(player_name, core.colorize("grey", S("Spectators : ") ..
    table.concat(spectators, ", ")))

    core.log("action", "[Minigame] Player " .. player_name .." is spectating")
end

function minigame.is_spectating(player)
    return player:get_meta():get_string("is_spectator") == "true"
end

function minigame.reset_player(player)
    local player_meta = player:get_meta()
    local player_name = player:get_player_name()
    local spawnpoint = core.settings:get_pos("static_spawnpoint")
    local max_hp = core.PLAYER_MAX_HP_DEFAULT

    if not core.is_creative_enabled(player_name) then minigame.clear_inventory(player) end
    if player:get_hp() ~= max_hp then player:set_hp(max_hp) end

    if minigame.HIDE_NAMETAGS and player:get_nametag_attributes().text == " " then
        player:set_nametag_attributes({text = player_name, color = {a=255, r=255, g=255, b=255}})
    end

    if minigame.is_spectating(player) then
        if not core.is_creative_enabled(player_name) then
            core.change_player_privs(player_name, {interact = true, fly = false, fast = false})
        end

        player:set_properties({
            pointable = true,
            visual_size = {x = 1, y = 1},
            is_visible = true,
            makes_footstep_sound = true,
            show_on_minimap = true
        })

        player_meta:set_string("is_spectator", "false")
    end

    if player_index[player:get_player_name()] then player_index[player:get_player_name()] = nil end

    if spawnpoint then player:set_pos(spawnpoint)
    else player:respawn() end
end

function minigame.teleport_player_to_spawn(player, map, spawn_index)
    local pos = map.spawns[spawn_index] or map.spawns[1]
    player:set_pos(pos)
end

function minigame.is_player_outside(player, map)
    local player_pos = player:get_pos()
    local map_pos1, map_pos2 = map.pos1, map.pos2

    if map_pos1 and map_pos2 then
        if player_pos.x < math.min(map_pos1.x, map_pos2.x) or player_pos.x > math.max(map_pos1.x, map_pos2.x) or
            player_pos.y < math.min(map_pos1.y, map_pos2.y) or player_pos.y > math.max(map_pos1.y, map_pos2.y) or
            player_pos.z < math.min(map_pos1.z, map_pos2.z) or player_pos.z > math.max(map_pos1.z, map_pos2.z) then
            return true
        end
    end

    return false
end

function minigame.check_and_teleport_players(map)
    for i, player in ipairs(minigame.get_players(map)) do
        if minigame.is_player_outside(player, map) then
            minigame.teleport_player_to_spawn(player, map, i)

            core.chat_send_player(player:get_player_name(),
            core.colorize("#F4320B", S("You are not allowed to cross the barrier!")))
        end
    end

    for i, spectator in ipairs(minigame.get_spectators(map)) do
        if minigame.is_player_outside(spectator, map) then
            minigame.teleport_player_to_spawn(spectator, map, i)

            core.chat_send_player(spectator:get_player_name(),
            core.colorize("#F4320B", S("You are not allowed to cross the barrier!")))
        end
    end
end

function minigame.create_schematic(game_name, map_name)
    local path = minigame_path .. "/" .. game_name
    local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
    local name = (map_name:lower()):gsub("%s", "_")

    map.pos1, map.pos2 = vector.sort(map.pos1, map.pos2)

    core.mkdir(path)

    core.create_schematic(map.pos1, map.pos2, nil, path .. "/" .. name .. ".mts")
end

function minigame.place_schematic(game_name, map_name)
    local name = (map_name:lower()):gsub("%s", "_")
    local path = minigame_path .. "/" .. game_name .. "/" .. name .. ".mts"
    local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)

    map.pos1, map.pos2 = vector.sort(map.pos1, map.pos2)

    core.place_schematic(map.pos1, path, "0", nil, true)
end

function minigame.disable_map(map, value)
    map.activated = value
end

function minigame.map_enabled(map)
    if map.activated ~= nil then
        return map.activated
    end

    return true
end

local function load_maps()
    local file = io.open(data_path, "r")
    if file then
        local content = file:read("*all")
        file:close()

        local data = core.parse_json(content)
        if data and type(data) == "table" then
            for game_name, game_maps in pairs(data) do
                if minigame[game_name] then
                    minigame[game_name].maps = game_maps

                    core.log("action", "[Minigame] Maps found for " .. game_name)
                end
            end
        end
    else
        core.mkdir(minigame_path)

        local new_file = io.open(data_path, "w")
        if new_file then
            new_file:write(core.write_json({}, true))
            new_file:close()
        end
    end
end
core.after(0.1, load_maps)

function minigame.reload_maps()
    core.chat_send_all(minigame_prefix .. S("Reloading maps ..."))
    -- Kick players in-game
    for _, game_name in ipairs(minigame.get_all_games()) do
        for _, map_name in ipairs(minigame.get_maps(game_name)) do
            local _, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
            if map.players and #map.players ~= 0 or map.spectators and #map.spectators ~= 0 then
                minigame.end_game(game_name, map_name)
            end
        end
    end
    -- Reload maps
    load_maps()
end

function minigame.save_maps()
    local maps_data = {}
    for game_name, game_data in pairs(minigame) do
        if type(game_data) == "table" and game_data.maps then
            maps_data[game_name] = game_data.maps
        end
    end

    local file = io.open(data_path, "w")
    if file then
        local json_data = core.write_json(maps_data, true)
        file:write(json_data)
        file:close()
        core.log("action", "[Minigame] File found, maps saved successfully")
    else
        core.log("error", "[Minigame] Unable to find the file and save the maps")
    end
end