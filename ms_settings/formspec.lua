function ms_settings.show_settings(player_name, category)
    local formspec = [[
        size[11,9]
        box[0,0;2.7,9;#3B3B3B]
        style_type[button;bgcolor=#4B6EA7;font=bold]
        style_type[checkbox;sound=ms_settings_click]
    ]]

    local btn_y = 0.2
    for _, k in pairs(ms_settings.categories) do
        local name = k:lower()
        formspec = formspec..("button[0.2,%.1f;2.5,1.5;%s;%s]"):format(btn_y, name, k)

        btn_y = btn_y + 1.2
    end

    -- Settings
    formspec = formspec .. [[
        box[3,0;7.5,9;#3B3B3B]
        scrollbaroptions[max=100]
        scrollbar[10.6,0;0.4,9;vertical;settings;0]
        scroll_container[4,0.5;9,10;settings;vertical]
    ]]

    local y = 0
    for k, v in pairs(ms_settings.settings) do
        if v.category:lower() == category then
            --local name = k:gsub("%s", "_")
            local desc = v.label or ""
            local value = ms_settings.get(core.get_player_by_name(player_name), k)

            if v.type == "bool" and value then
                formspec = formspec .. ("checkbox[0,%.1f;%s;%s;true]"):format(y, k, core.colorize("green", desc))
            elseif v.type == "bool" and not value then
                formspec = formspec .. ("checkbox[0,%.1f;%s;%s;false]"):format(y, k, desc)
            end

            y = y + 1.1
        end
    end

    formspec = formspec .. "scroll_container_end[]"

    core.show_formspec(player_name, "ms_settings:settings_page", formspec)
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "ms_settings:settings_page" then
        for _, v in pairs(ms_settings.categories) do
            local category = v:lower()
            if fields[category] then
                ms_settings.show_settings(player:get_player_name(), category)
                break
            end
        end

        for k, v in pairs(ms_settings.settings) do
            if fields[k] then
                local enabled = ms_settings.get(player, k)
                if enabled then ms_settings.set(player, k, "false")
                else ms_settings.set(player, k, "true") end
                ms_settings.show_settings(player:get_player_name(), v.category:lower())

                if v.on_change then v.on_change(player, ms_settings.get(player, k)) end

                break
            end
        end
    end
end)

core.register_chatcommand("settings", {
    description = "Display settings GUI",
    func = function(name)
        if not core.get_player_by_name(name) then return end
        ms_settings.show_settings(name, ms_settings.categories[1]:lower())
    end
})