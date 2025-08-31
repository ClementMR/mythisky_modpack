mythisky = {}

mythisky.DEATH_LAYER    = core.settings:get("death_layer") or -100
mythisky.TIPS           = core.settings:get("tips_timer") or 900
mythisky.DISCORD        = core.settings:get("discord_link") or "https://discord.com/invite/qrrWwrS6Sv"

local modpath = core.get_modpath(core.get_current_modname())

local files = {
    "player",
    "chat",
    "nodes",
    "inventory",
    "tips"
}

for _, file in ipairs(files) do
    dofile(modpath .. "/" .. file .. ".lua")
end

local function update()
    if core.is_singleplayer() then return end

    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        if player and pos.y <= mythisky.DEATH_LAYER and not core.check_player_privs(player, {creative=true}) then
            player:set_hp(0)
        end
    end

    core.after(2, update)
end

core.after(0.1, update)