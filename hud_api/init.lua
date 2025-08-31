hud_api = {
    huds = {} -- Store HUDs
}

function hud_api.show_front(player, text, color)
    local name = player:get_player_name():lower()
    local hud_id = "hud_api:" .. name .. "_front"

    text = text or ""
    color = color or "0xFFFFFF"

    if hud_api.huds[hud_id] and color ~= hud_api.huds[hud_id].color then hud_api.remove(player, "front") end

    if hud_api.huds[hud_id] then
        player:hud_change(hud_api.huds[hud_id].id, "text", text)

        return
    end

    hud_api.huds[hud_id .. "_bg"] = {
        id = player:hud_add({
            type = "image",
            text = "hud_api_hud_bg.png",
            scale = {x = 5, y = 3},
            position = {x = 0.5, y = 0.3},
            z_index = 0
        })
    }

    hud_api.huds[hud_id] = {
        id = player:hud_add({
            type = "text",
            text = text,
            number = color,
            size = {x = 2, y = 2},
            position = {x =  0.5, y = 0.3},
            z_index = 100,
            style = 1
        }),
        color = color
    }
end

function hud_api.show_actionbar(player, text, color)
    local name = player:get_player_name():lower()
    local hud_id = "hud_api:" .. name .. "_actionbar"

    text = text or ""
    color = color or "0xFFFFFF"

    if hud_api.huds[hud_id] and color ~= hud_api.huds[hud_id].color then hud_api.remove(player, "actionbar") end

    if hud_api.huds[hud_id] then
        player:hud_change(hud_api.huds[hud_id].id, "text", text)

        return
    end

    hud_api.huds[hud_id .. "_bg"] = {
        id = player:hud_add({
            type = "image",
            text = "hud_api_hud_bg.png",
            scale = {x = 1.4, y = 1.4},
            position = {x = 0.5, y = 0.8},
            z_index = 0
        })
    }

    hud_api.huds[hud_id] = {
        id = player:hud_add({
            type = "text",
            text = text,
            number = color,
            size = {x = 1.1, y = 1.1},
            position = {x =  0.5, y = 0.8},
            z_index = 100
        }),
        color = color
    }
end

function hud_api.get(player, hud_type)
    local name = player:get_player_name():lower()
    if not hud_type then hud_type = "front" end
    local id = "hud_api:" .. name .. "_" .. hud_type

    for k, _ in pairs(hud_api.huds) do
        if k:find(id) then
            return true
        end
    end

    return false
end

function hud_api.remove(player, hud_type)
    local name = player:get_player_name():lower()
    if not hud_type then hud_type = "front" end
    local id = "hud_api:" .. name .. "_" .. hud_type

    for k, _ in pairs(hud_api.huds) do
        if k:find(id) then
            player:hud_remove(hud_api.huds[k].id)
            hud_api.huds[k] = nil
        end
    end
end

function hud_api.remove_all(player)
    local name = player:get_player_name():lower()
    for k, _ in pairs(hud_api.huds) do
        if k:find("hud_api:" .. name) then
            player:hud_remove(hud_api.huds[k].id)
            hud_api.huds[k] = nil
        end
    end
end

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name():lower()
    for k, _ in pairs(hud_api.huds) do
        if k:find("hud_api:" .. name) then
            hud_api.huds[k] = nil
        end
    end
end)

--[[
core.register_chatcommand("get_huds", {
    privs = {server = true},
    description = "Get all HUDs",
    func = function(_, _)
        return true, dump(hud_api.huds)
    end
})
]]