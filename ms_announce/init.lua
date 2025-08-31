local S = core.get_translator(core.get_current_modname())

local worldpath = core.get_worldpath()

local function read_file(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
    return "This page is empty."
end

local function show_announce(player_name)
    local formspec =
        "size[5.5,9]"..
        "position[0.8,0.5]"..
        "no_prepend[]"..
        "bgcolor[;neither]"..
        "background[0,0;0,0;ms_announce_bg.png;1]"..
        "style_type[button_exit;noclip=true;bgcolor=#FF0000]"..
        "button_exit[5.7,-0.8;0.8,1;btn_exit;X]"..
        "hypertext[0.1,1.2;5.7,9.0;;" .. core.formspec_escape(read_file(worldpath .. "/announce.txt")) .. "]"

    core.show_formspec(player_name, "ms_announce:form", formspec)
end

ms_settings.register("show_announce", {
    type = "bool",
    default = true,
    label = S("Show the announcements when you join the game"),
    category = "Misc"
})

core.register_on_joinplayer(function(player)
    if not ms_settings.get(player, "show_announce") then return end
    show_announce(player:get_player_name())
end)

for _, cmd in ipairs({"announcement", "ann"}) do
    core.register_chatcommand(cmd, {
        description = S("Show the announcements page"),
        func = function(player_name)
            if not core.get_player_by_name(player_name) then return end

            show_announce(player_name)
        end
    })
end