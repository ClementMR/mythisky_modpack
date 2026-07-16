local S = core.get_translator(core.get_current_modname())

local tips = {
    S("Use @1 or @2 to leave a minigame.", "/quit", "/leave"),
    S("You can use @1 to teleport to the lobby.", "/lobby"),
    S("Use @1 for a list of commands.", "/help"),
    S("Use @1 to change your skin.", "/skin"),
    S("Use @1 to send a suggestion.", "/suggestion <message>"),
    S("Use @1 to change your settings.", "/settings"),
    S("Use @1 to leave FFA.", "/ffa_leave"),
    S("Use @1 to see who's in FFA.", "/ffa_whois")
}

local timer = ms_main.TIPS

local function show_tips()
    if timer == 0 then
        local msg = tips[math.random(#tips)]
        for _, player in ipairs(core.get_connected_players()) do
            core.chat_send_player(player:get_player_name(), core.colorize("#808080", S("[Tips] @1", msg)))
        end

        timer = ms_main.TIPS
    end

    core.after(1, show_tips)
    timer = timer - 1
end

core.after(0, show_tips)
