ms_settings = {
    settings = {},
    categories = {
        --"Audio",
        "Hud",
        "Misc",
        "Particles",
    }
}

function ms_settings.register(name, def)
    if ms_settings.settings[name] then
        error("The setting "..name.." already exists!")
    end

    ms_settings.settings[name] = def
end

function ms_settings.set(player, setting_name, value)
    player:get_meta():set_string("ms_settings:"..setting_name, value)
end

function ms_settings.get(player, setting_name)
    local value = player:get_meta():get_string("ms_settings:"..setting_name)
    local setting = ms_settings.settings[setting_name]

    if value == "" then
        return setting and setting.default
    end

    return value == "true"
end

core.register_chatcommand("all_settings", {
    privs = {server=true},
    func = function(name)
        for k, _ in pairs(ms_settings.settings) do
            core.chat_send_player(name, "Setting: "..k.."\n")
        end
    end
})

dofile(core.get_modpath(core.get_current_modname()).."/formspec.lua")