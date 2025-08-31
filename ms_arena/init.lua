in_arena = {
    SPEED = 1.6
}

local modpath = core.get_modpath(core.get_current_modname())
local S = core.get_translator(core.get_current_modname())

dofile(modpath .. "/items.lua")
dofile(modpath .. "/ctf_shotgun.lua")

core.register_privilege("arena_bypass", {
    description = "Can bypass arena system",
    give_to_singleplayer = false,
})

local function add_items(player, stack)
    local inv = player:get_inventory()

    if stack then
        inv:set_list("main", {})
        inv:set_list("craft", {})

        for _, v in ipairs(stack) do
            inv:set_stack("main", v.slot, v.item)
        end
    else
        inv:set_list("main", {})
        inv:set_list("craft", {})
    end
end

local function set_arena_speed(player, speed)
    player:set_physics_override({speed = speed})
end

function in_arena.manage_player(player)
    local player_name = player:get_player_name()
    if core.get_player_privs(player_name).arena_bypass then return end

    local pos = vector.round(player:get_pos())
    local areas = areas:getAreasAtPos(pos) or {}
    local area_open = false
    for _, area in pairs(areas) do
        if area.open then
            area_open = true
            break
        end
    end

    local in_zone = in_arena[player_name]

    if in_zone and not area_open then
        -- Le joueur sort de l'arène
        add_items(player, {})
        set_arena_speed(player, 1.0)
        in_arena[player_name] = nil

    elseif area_open and not in_zone then
        -- Le joueur entre dans l'arène
        add_items(player, {
            {item = "ms_arena:sword_mese", slot = 1},
            {item = "ms_arena:apple",      slot = 2},
            {item = "ms_arena:shotgun",    slot = 8}
        })

        set_arena_speed(player, in_arena.SPEED)
        in_arena[player_name] = true

        hud_api.show_front(player, S("COMBAT ZONE"), "0xF0250D")
        core.after(2, hud_api.remove, player, "front")

    elseif area_open and in_zone then
        -- Check si la vitesse est bonne
        if player:get_physics_override().speed ~= in_arena.SPEED then
            set_arena_speed(player, in_arena.SPEED)
        end
    end
end

local timer
core.register_globalstep(function(dtime)
    timer = (timer or 0) + dtime
    if timer > 1 then
        timer = 0
        for _, player in ipairs(core.get_connected_players()) do
            in_arena.manage_player(player)
        end
    end
end)

core.register_on_punchplayer(function(player, hitter)
    if not hitter or not hitter:is_player() then return end

    local player_name = hitter:get_player_name()
    local target_name = player:get_player_name()

    if not areas:canInteract(vector.round(player:get_pos()), player_name) then
        if in_arena[player_name] and in_arena[target_name] then
            return false
        end

        return true
    end
end)

core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    if in_arena[player_name] then
        add_items(player, {})
        in_arena[player_name] = nil
    end
end)