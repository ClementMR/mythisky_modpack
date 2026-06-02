local VALID_INVENTORY_MODES = {
    clear = true,
    keep = true,
    persistent = true,
}

local DEFAULT_INVENTORY_LISTS = {"main", "craft"}
local LOBBY_INVENTORY_KEY = "minigame_api:lobby_inventory"

local function get_inventory_key(game_name)
    return "minigame_api:game_inventory:" .. game_name
end

local function normalize_inventory_mode(value)
    if VALID_INVENTORY_MODES[value] then
        return value
    end

    return "clear"
end

local function get_player_settings(game)
    if game and game.settings and game.settings.player then
        return game.settings.player
    end

    return minigame.normalize_player_settings({})
end

local function get_inventory_options(settings)
    return {
        lists = settings.inventory_lists,
        include_armor = settings.include_armor,
    }
end

function minigame.normalize_player_settings(def)
    def = def or {}

    local inventory_mode = normalize_inventory_mode(def.inventory_mode or def.player_inventory)
    local save_lobby_inventory = ms_utils.bool_or(def.save_lobby_inventory, false)
    local include_armor = def.include_armor

    if include_armor == nil then
        include_armor = inventory_mode == "persistent" or save_lobby_inventory
    end

    return {
        inventory_mode = inventory_mode,
        save_lobby_inventory = save_lobby_inventory,
        include_armor = include_armor,
        inventory_lists = ms_utils.copy_sequence(def.inventory_lists, DEFAULT_INVENTORY_LISTS),
    }
end

function minigame.get_player_state_settings(game_name)
    return get_player_settings(minigame.get_game(game_name))
end

function minigame.get_saved_inventory_key(game_name)
    return get_inventory_key(game_name)
end

function minigame.save_player_inventory(player, game_name)
    local game = minigame.get_game(game_name)
    if not game then
        return false
    end

    local settings = get_player_settings(game)
    ms_utils.player.save_inventory(player, get_inventory_key(game_name), get_inventory_options(settings))
    return true
end

function minigame.restore_player_inventory(player, game_name)
    local game = minigame.get_game(game_name)
    if not game then
        return false
    end

    local settings = get_player_settings(game)
    return ms_utils.player.restore_saved_inventory(player, get_inventory_key(game_name), get_inventory_options(settings))
end

function minigame.clear_player_inventory(player, game_name)
    local settings = minigame.get_player_state_settings(game_name)
    ms_utils.player.clear_inventory(player, get_inventory_options(settings))
end

function minigame.apply_player_join_state(player, game_name)
    local game = minigame.get_game(game_name)
    local settings = get_player_settings(game)
    local options = get_inventory_options(settings)

    if settings.save_lobby_inventory then
        ms_utils.player.save_inventory(player, LOBBY_INVENTORY_KEY, options)
    end

    if settings.inventory_mode == "keep" then
        return
    end

    if settings.inventory_mode == "persistent" then
        if ms_utils.player.restore_saved_inventory(player, get_inventory_key(game_name), options) then
            return
        end
    end

    ms_utils.player.clear_inventory(player, options)
end

function minigame.apply_player_exit_state(player, game_name, options)
    options = options or {}

    local game = minigame.get_game(game_name)
    local settings = get_player_settings(game)
    local inventory_options = get_inventory_options(settings)
    local save_game_inventory = options.save_game_inventory ~= false

    if settings.inventory_mode == "persistent" and game_name and save_game_inventory then
        ms_utils.player.save_inventory(player, get_inventory_key(game_name), inventory_options)
    end

    if settings.save_lobby_inventory then
        if ms_utils.player.restore_saved_inventory(player, LOBBY_INVENTORY_KEY, inventory_options) then
            ms_utils.player.delete_saved_inventory(player, LOBBY_INVENTORY_KEY)
            return
        end
    end

    if settings.inventory_mode ~= "keep" then
        ms_utils.player.clear_inventory(player, inventory_options)
    end
end