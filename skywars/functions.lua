function skywars.find_random_spawn(player_name, map_name)
    local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)
    local spawns = minigame.get_spawns(map)

    skywars.spawns[map_name] = skywars.spawns[map_name] or {}
    local state = skywars.spawns[map_name]
    state.taken = state.taken or {}

    local free = {}
    for i = 1, #spawns do if not state.taken[i] then free[#free+1] = i end end
    if #free == 0 then return nil end

    local index = free[math.random(#free)]

    state.taken[index] = player_name

    return spawns[index]
end

local function get_spawn_index(player_name, map_name)
    local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)
    local spawns = minigame.get_spawns(map)
    local spawn_taken = skywars.spawns[map_name].taken

    if spawn_taken then
        for i=1, #spawns do
            if spawn_taken[i] == player_name then
                return i
            end
        end
    end

    return nil
end

function skywars.clear_spawn(player_name, map_name)
    local i = get_spawn_index(player_name, map_name)
    if not i then return end

    skywars.spawns[map_name].taken[i] = nil
end

local function get_player_spawn(player, map_name)
    local _, map = minigame.get_gamedef_and_mapdef(skywars.game_name, map_name)
    if not map.spawns then return end

    local i = get_spawn_index(player:get_player_name(), map_name)
    if not i then return end

    return map.spawns[i]
end

function skywars.check_distance_and_teleport(player, map_name)
    local pos = get_player_spawn(player, map_name)
    if not pos then return end
    if vector.distance(pos, player:get_pos()) > 2 then player:set_pos(pos) end
end

function skywars.set_box(pos)
    local height, width, depth = 4, 3, 3
    local empty_pos = {{x = 0, y = 1, z = 0}, {x = 0, y = 2, z = 0}}
    for y = 0, height - 1 do
        for x = -math.floor(width / 2), math.floor(width / 2) do
            for z = -math.floor(depth / 2), math.floor(depth / 2) do
                local new_pos = {x = pos.x - x, y = pos.y + y - 1, z = pos.z - z}
                local inside = false

                for _, p in ipairs(empty_pos) do
                    if -x == p.x and y == p.y and -z == p.z then
                        inside = true
                        break
                    end
                end

                if not inside then core.set_node(new_pos, {name = "skywars:box"}) end
            end
        end
    end
end

function skywars.remove_box(pos)
    local height, width, depth = 4, 3, 3
    for y = 0, height - 1 do
        for x = -math.floor(width / 2), math.floor(width / 2) do
            for z = -math.floor(depth / 2), math.floor(depth / 2) do
                core.remove_node({x = pos.x - x, y = pos.y + y - 1, z = pos.z - z})
            end
        end
    end
end

function skywars.clear_armor(player, drop)
    local armor_enabled = core.global_exists("armor")
    if not armor_enabled then return end

    local name, armor_inv = armor:get_valid_player(player, "[on_dieplayer]")
    if not name or not armor_inv then return end

    local list = {}
    for i=1, armor_inv:get_size("armor") do
        local stack = armor_inv:get_stack("armor", i)
        if stack:get_count() > 0 then
            table.insert(list, stack)
        end

        armor_inv:set_stack("armor", i, nil)
    end

    armor:save_armor_inventory(player)
    armor:set_player_armor(player)

    if drop then
        local pos = player:get_pos() ; if not pos then return end
        for _, stack in ipairs(list) do
            armor.drop_armor(pos, stack)
        end
    end
end

local function refill_chest(pos, map)
    local inv = core.get_meta(pos):get_inventory()
    local loot = map.loot
    if loot then
        for _, l in pairs(loot) do
            if math.random() < l.chance then
                local slot = math.random(1, 32)
                local count = math.random(1, l.max or 99)
                local stack = ItemStack(l.item .. " " .. count)

                inv:set_stack("main", slot, stack)
            end
        end
    end
end

function skywars.place_chests(map)
    local chests = map.chests
    if chests then
        for _, chest in pairs(chests) do
            local pos = chest.pos
            local param2 = chest.param2 or 0

            core.set_node(pos, {name = "default:chest", param2 = param2})
            refill_chest(pos, map)
        end
    end
end