ms_utils.player = {}

local DEFAULT_INVENTORY_LISTS = {"main", "craft"}

local function get_inventory_lists(options)
    options = options or {}
    return ms_utils.copy_sequence(options.lists, DEFAULT_INVENTORY_LISTS)
end

local function get_armor_inventory(player, reason)
    if not core.global_exists("armor") or type(armor.get_valid_player) ~= "function" then
        return nil
    end

    local _, armor_inv = armor:get_valid_player(player, reason or "[ms_utils]")
    return armor_inv
end

function ms_utils.player.serialize_inventory(player, options)
    local inv = player:get_inventory()
    local data = {
        lists = {},
    }

    for _, list_name in ipairs(get_inventory_lists(options)) do
        local list = inv:get_list(list_name)
        if list then
            data.lists[list_name] = {}

            for _, item in ipairs(list) do
                table.insert(data.lists[list_name], item:to_string())
            end
        end
    end

    options = options or {}
    if options.include_armor then
        data.armor = ms_utils.player.serialize_armor(player)
    end

    return data
end

function ms_utils.player.serialize_armor(player)
    local armor_inv = get_armor_inventory(player, "[ms_utils:serialize_armor]")
    if not armor_inv then
        return nil
    end

    local list = armor_inv:get_list("armor")
    if not list then
        return nil
    end

    local data = {}
    for _, item in ipairs(list) do
        table.insert(data, item:to_string())
    end

    return data
end

function ms_utils.player.restore_inventory(player, data, options)
    if type(data) ~= "table" then
        return false
    end

    options = options or {}
    local lists = data.lists or data
    local inv = player:get_inventory()

    for _, list_name in ipairs(get_inventory_lists(options)) do
        if inv:get_list(list_name) then
            inv:set_list(list_name, {})
        end
    end

    for list_name, list_data in pairs(lists) do
        if list_name ~= "armor" and type(list_data) == "table" and inv:get_list(list_name) then
            for index, item in ipairs(list_data) do
                inv:set_stack(list_name, index, ItemStack(item))
            end
        end
    end

    if options.include_armor then
        ms_utils.player.restore_armor(player, data.armor)
    end

    return true
end

function ms_utils.player.restore_armor(player, armor_data)
    if type(armor_data) ~= "table" then
        return false
    end

    local armor_inv = get_armor_inventory(player, "[ms_utils:restore_armor]")
    if not armor_inv then
        return false
    end

    local list = {}
    for index, item in ipairs(armor_data) do
        list[index] = ItemStack(item)
    end

    armor_inv:set_list("armor", list)

    if type(armor.set_player_armor) == "function" then
        armor:set_player_armor(player)
    end

    if type(armor.save_armor_inventory) == "function" then
        armor:save_armor_inventory(player)
    end

    return true
end

function ms_utils.player.clear_inventory(player, options)
    local inv = player:get_inventory()

    for _, list_name in ipairs(get_inventory_lists(options)) do
        if inv:get_list(list_name) then
            inv:set_list(list_name, {})
        end
    end

    options = options or {}
    if options.include_armor then
        ms_utils.player.clear_armor(player)
    end
end

function ms_utils.player.set_inventory_items(player, items, options)
    options = options or {}
    local list_name = options.list or "main"
    local inv = player:get_inventory()

    ms_utils.player.clear_inventory(player, options)

    if type(items) ~= "table" or not inv:get_list(list_name) then
        return
    end

    for _, stack in ipairs(items) do
        if stack.slot and stack.item then
            local target_list = stack.list or list_name
            if inv:get_list(target_list) then
                inv:set_stack(target_list, stack.slot, stack.item)
            end
        end
    end
end

function ms_utils.player.clear_armor(player)
    if core.global_exists("armor") and type(armor.remove_all) == "function" then
        armor:remove_all(player)
        return true
    end

    local armor_inv = get_armor_inventory(player, "[ms_utils:clear_armor]")
    if not armor_inv then
        return false
    end

    armor_inv:set_list("armor", {})
    return true
end

function ms_utils.player.save_inventory(player, key, options)
    local data = ms_utils.player.serialize_inventory(player, options)
    player:get_meta():set_string(key, core.serialize(data))
    return data
end

function ms_utils.player.get_saved_inventory(player, key)
    local raw = player:get_meta():get_string(key)
    if raw == "" then
        return nil
    end

    return core.deserialize(raw)
end

function ms_utils.player.has_saved_inventory(player, key)
    return ms_utils.player.get_saved_inventory(player, key) ~= nil
end

function ms_utils.player.restore_saved_inventory(player, key, options)
    local data = ms_utils.player.get_saved_inventory(player, key)
    if not data then
        return false
    end

    return ms_utils.player.restore_inventory(player, data, options)
end

function ms_utils.player.delete_saved_inventory(player, key)
    player:get_meta():set_string(key, "")
end

function ms_utils.player.get_spawnpoint()
    return core.settings:get_pos("static_spawnpoint")
end

function ms_utils.player.teleport_to_spawn(player)
    local spawnpoint = ms_utils.player.get_spawnpoint()
    if spawnpoint then
        player:set_pos(spawnpoint)
        return true
    end

    player:respawn()
    return false
end

function ms_utils.player.reset_health(player)
    local max_hp = core.PLAYER_MAX_HP_DEFAULT or 20
    if player:get_hp() ~= max_hp then
        player:set_hp(max_hp)
    end
end

function ms_utils.player.set_minimap(player, enabled)
    player:hud_set_flags({
        minimap = enabled,
        minimap_radar = enabled,
    })
end
