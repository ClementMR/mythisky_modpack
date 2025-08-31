local S = core.get_translator(core.get_current_modname())

local function get_map_image(map_name)
    return (map_name:lower()):gsub("%s", "_") .. "_screenshot.png"
end

local function show_editor_form(player_name, pos, game_name, map_name)
    local games = minigame.get_all_games()
    local maps = minigame.get_maps(game_name)
    local form = "size[7,3.5]" ..
        "dropdown[0.5,0.3;6,1;game_name;" .. table.concat(games, ",") .. ";" ..
        (table.indexof(games, game_name) or 1) .. "]" ..
        "dropdown[0.5,1.3;6,1;map_name;" .. table.concat(maps, ",") .. ";" ..
        (table.indexof(maps, map_name) or 1) .. "]" ..
        "button_exit[3.3,2.5;2,1;remove_btn;Remove]" ..
        "button_exit[1.3,2.5;2,1;submit_btn;Submit]"

    core.show_formspec(player_name, "minigame_access:editor_" .. core.pos_to_string(pos), form)
end

local function show_map_form(player_name, pos, game_name, map_name)
    local game, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
    if not game or not map then return end

    local btn_pl_bgcolor = "#00FF00"
    local btn_spec_bgcolor = "#FF0000"

    local map_info = minigame.get_map_information(game, map)
    local running = map_info.running
    local max_players = map_info.max_players
    local current_players = minigame.get_players(map) or 0
    local image = get_map_image(map_name)

    local players = {}
    for _, player in ipairs(current_players) do
        table.insert(players, player:get_player_name())
    end

    if running then
        btn_pl_bgcolor = "#FF0000"
        btn_spec_bgcolor = "#00FF00"
    end

    local form = "size[15,8]" ..
        "no_prepend[]" ..
        "bgcolor[;neither]" ..
        "background[0,0;0,0;minigame_access_bg.png;true]" ..

        "hypertext[1,0.5;9.2,1.5;map_info;<big><u>" ..
        ("Game : %s | Map : %s"):format(game_name:gsub("_", " "), map_name) .. "</big></u>]" ..
        "background[0.5,2;8.25,5;" .. image .. "]" ..

        "label[11,0;" .. S("Online (@1/@2) :", #current_players, max_players) .. "]" ..
        "table[10.5,0.8;4.4,7.3;online_players;" .. table.concat(players, ",") .. "]" ..

        "style[play_btn;bgcolor=" ..  btn_pl_bgcolor .. "]" ..
        "style[watch_btn;bgcolor=" .. btn_spec_bgcolor .. "]" ..
        "style[exit_btn;noclip=true;bgcolor=#FF0000]"..
        "button_exit[1,7.2;3.5,1;play_btn;" .. S("Play") .."]" ..
        "button_exit[4.9,7.2;3.5,1;watch_btn;" .. S("Watch") .."]" ..
        "button_exit[15.2,-0.8;0.8,1;exit_btn;X]"

    core.show_formspec(player_name, "minigame_access:map_" .. core.pos_to_string(pos), form)
end

core.register_node("minigame_access:teleporter", {
    description = "Minigame Teleporter",
    drawtype = "nodebox",
    tiles = {
        "default_steel_block.png",
        "default_steel_block.png",
        "default_steel_block.png",
        "default_steel_block.png",
        "default_steel_block.png",
        "default_steel_block.png^default_sign_steel.png",
    },
    paramtype2 = "facedir",
    sunlight_propagates = true,
    is_ground_content = false,
    groups = {cracky=3},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.2, 0.5, 0.5, 0.2},
        },
    },
    on_rightclick = function(pos, _, clicker, _, _)
        local meta = core.get_meta(pos)
        local game_name = meta:get_string("game_name")
        local map_name = meta:get_string("map_name")
        local clicke_name = clicker:get_player_name()

        if game_name == "" or map_name == "" then
            core.chat_send_player(clicke_name, core.colorize("#F4320B", S("A map editor must set one first!")))
        else
            show_map_form(clicke_name, pos, game_name, map_name)
        end
    end,
    on_punch = function(pos, _, puncher, _)
        local meta = core.get_meta(pos)
        local game_name = meta:get_string("game_name")
        local map_name = meta:get_string("map_name")
        local puncher_name = puncher:get_player_name()

        if puncher:get_wielded_item():get_name() == "minigame_access:edit_stick" then
            show_editor_form(puncher_name, pos, game_name, map_name)
            return
        end

        if game_name == "" or map_name == "" then
            core.chat_send_player(puncher_name, core.colorize("#F4320B", S("A map editor must set one first!")))
        else
            minigame.join_game(puncher, game_name, map_name)
        end
    end,
    on_destruct = function(pos)
        for _, obj in pairs(core.get_objects_inside_radius(pos, 2)) do
            local entity = obj:get_luaentity()
            if entity and entity.name == "minigame_access:map_screenshot" then
                obj:remove()
            end
        end
    end
})

core.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()

    if formname:sub(0, 23) == "minigame_access:editor_" then
        local pos = core.string_to_pos(formname:sub(24))
        local meta = core.get_meta(pos)

        if fields.submit_btn then
            local game_name = fields.game_name or ""
            local map_name = fields.map_name or ""

            meta:set_string("game_name", game_name)
            meta:set_string("map_name", map_name)
            meta:set_string("infotext", "Game: " .. game_name .. "\nMap: " .. map_name)

            for _, obj in pairs(core.get_objects_inside_radius(pos, 2)) do
                local entity = obj:get_luaentity()
                if entity and entity.name == "minigame_access:map_screenshot" then
                    obj:remove()
                end
            end

            if game_name ~= "" and map_name ~= "" then
                local ent = core.add_entity({x=pos.x, y=pos.y+1.25, z=pos.z}, "minigame_access:map_screenshot")
                local image = get_map_image(map_name)
                if ent then
                    local luaent = ent:get_luaentity()
                    luaent.screenshot = image
                    luaent.yaw = player:get_look_horizontal() or 0

                    luaent.object:set_properties({textures = {image}})
                    luaent.object:set_yaw(player:get_look_horizontal() or 0)
                end
            end

            show_editor_form(player_name, pos, game_name, map_name)
        elseif fields.remove_btn then
            core.remove_node(pos)
            core.chat_send_player(player_name, "Teleporter successfully removed!")
        end
    elseif formname:sub(0, 20) == "minigame_access:map_" then
        local pos = core.string_to_pos(formname:sub(21))
        local meta = core.get_meta(pos)
        local game_name = meta:get_string("game_name")
        local map_name = meta:get_string("map_name")
        local game, map = minigame.get_gamedef_and_mapdef(game_name, map_name)
        local running = minigame.get_map_information(game, map).running

        if fields.play_btn then
            minigame.join_game(player, game_name, map_name)
        elseif fields.watch_btn then
            if running and not minigame.is_spectating(player) then
                minigame.add_spectator(player, game_name, map_name)
            else
                core.chat_send_player(player_name,
                core.colorize("#F4320B", S("You are not able to spectate this map!")))
            end
        end
    end
end)

core.register_entity("minigame_access:map_screenshot", {
    initial_properties = {
        visual = "upright_sprite",
        textures = {"blank.png"},
        visual_size = {x=1.2, y=1},
        pointable = false
    },
	on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            local data = core.deserialize(staticdata)
            if data then
                self.screenshot = data.screenshot
                self.yaw = data.yaw
            end
        end

        self.object:set_properties({textures = {self.screenshot or "blank.png"}})
        self.object:set_yaw(self.yaw or 0)
	end,
	get_staticdata = function(self)
        return core.serialize({screenshot = self.screenshot, yaw = self.yaw})
	end
})

core.register_craftitem("minigame_access:edit_stick", {
    description = "Edit Stick",
    inventory_image = "default_stick.png^[colorize:#FFCC00",
    on_drop = function() return end
})