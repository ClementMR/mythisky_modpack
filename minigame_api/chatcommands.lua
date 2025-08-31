-- Local variables
local S = core.get_translator(core.get_current_modname())

local admin_prefix = "Admin-only : "

core.register_chatcommand("join", {
    description = S("Join a minigame"),
    params = S("<game_name> <map_name>"),
    privs = {interact=true},
    func = function(player_name, param)
        local player = core.get_player_by_name(player_name)
        if not player then return end

        local args = param:split(" ")
        if #args < 2 then
            return false, "Usage : /join " .. S("<game_name> <map_name>")
        end

        local game_name = args[1]
        local map_name = param:sub(#game_name + 2)

        minigame.join_game(player, game_name, map_name)
    end
})

core.register_chatcommand("add_player", {
    description = admin_prefix .. S("Add a player to a minigame"),
    params = S("<player_name> <game_name> <map_name>"),
    privs = {server=true},
    func = function(_, param)
        local args = param:split(" ")
        if #args < 3 then
            return false, "Usage : /add_player " .. S("<player_name> <game_name> <map_name>")
        end

        local player = core.get_player_by_name(args[1])
        if not player then
            return false, S("This player isn't online.")
        end

        local game_name = args[2]
        local map_name = param:sub(#player:get_player_name() + #game_name + 3)

        minigame.join_game(player, game_name, map_name)
    end
})

for _, cmd_name in ipairs({"quit", "leave"}) do
    core.register_chatcommand(cmd_name, {
        description = S("Leave the current map"),
        params = "",
        --privs = {interact=true},
        func = function(player_name)
            minigame.leave_game(core.get_player_by_name(player_name))
        end
    })
end

core.register_chatcommand("list_games", {
    description = S("List all games"),
    params = "",
    func = function()
        local output = core.colorize("green", S("List of games:"))
        for _, game in ipairs(minigame.get_all_games()) do
            output = output .. "\n- " .. game
        end

        return true, output
    end
})

core.register_chatcommand("list_maps", {
    description = S("List the maps of the specified game"),
    params = S("<game_name>"),
    func = function(_, param)
        if param == "" then
            return false, "Usage : /list_maps " .. S("<game_name>")
        end

        local maps = minigame.get_maps(param)
        if not maps then
            return false, S("Unable to find the game : @1", param)
        end

        local output = core.colorize("green", S("List of maps for @1 :", param))
        for _, game in ipairs(maps) do
            output = output .. "\n- " .. game
        end

        return true, output
    end
})

core.register_chatcommand("get_info", {
    description = admin_prefix .. S("Get the informations of the map specified"),
    params = S("<game_name> <map_name>"),
    privs = {server=true},
    func = function(_, param)
        local args = param:split(" ")
        if #args < 2 then
            return false, "Usage : /get_info " .. S("<game_name> <map_name>")
        end

        local game_name = args[1]
        local map_name = param:sub(#game_name + 2)
        local game, map = minigame.get_gamedef_and_mapdef(game_name, map_name)

        if not game then
            return false, S("Unable to find the game : @1", game_name)
        end

        if not map then
            return false, S("Unable to find the map : @1", map_name)
        end

        local output = core.colorize("green", S("Informations of the map : @1", map_name))
        for info_name, info_value in pairs(minigame.get_map_information(game, map)) do
            if type(info_value) == "boolean" then info_value = tostring(info_value) end
            output = output .. "\n- " .. info_name .. " : " .. info_value
        end

        return true, output
    end
})

core.register_chatcommand("watch", {
    description = admin_prefix .. S("Watch a map"),
    params = S("<game_name> <map_name>"),
    privs = {server=true},
    func = function(player_name, param)
        local player = core.get_player_by_name(player_name)
        local entry = minigame.get_player_entry(player)
        if not player or entry then return end

        local args = param:split(" ")
        if #args < 2 then
            return false, "Usage : /watch " .. S("<game_name> <map_name>")
        end

        local game_name = args[1]
        local map_name = param:sub(#game_name + 2)
        local game, map = minigame.get_gamedef_and_mapdef(game_name, map_name)

        if not game then
            return false, S("Unable to find the game : @1", game_name)
        end

        if not map then
            return false, S("Unable to find the map : @1", map_name)
        end

        minigame.add_spectator(player, game_name, map_name)

        return true, S("You are currently watching @1", map_name)
    end
})

core.register_chatcommand("reload_maps", {
    description = admin_prefix .. S("Reload maps"),
    privs = {server=true},
    func = function()
        minigame.reload_maps()

        return true, S("Reloading all maps ...")
    end
})