local nametags = {}

local function add_tag(player)
    local pos = player:get_pos()
    local ent = core.add_entity(pos, "playertag:tag")

    local str = player:get_player_name()
    local tag = player:get_meta():get_string("tag")
	local tag_len = 0
    if tag and tag ~= "" then
        str = "[" .. tag .. "]" .. player:get_player_name()
		tag_len = tag:len()+2
    end

    local texture = "npcf_tag_bg.png"
    local x = math.floor(134 - ((str:len() * 11) / 2))
    local i = 0
    local color = player:get_meta():get_string("tag_color") or "#FFFFFF"

    str:gsub(".", function(char)
        local n = "_"

		if char == "[" then n = "op_sb" elseif char == "]" then n = "cl_sb"
        elseif char:byte() > 96 and char:byte() < 123 or char:byte() > 47
		and char:byte() < 58 or char == "-" then n = char
        elseif char:byte() > 64 and char:byte() < 91 then n = "U" .. char end

		local colorize = ""
        if i/11 < tag_len then
            colorize = "^[colorize:" .. color
		end

		texture = texture.."^[combine:84x14:"..(x+i+1)..",1=(W_".. n ..".png\\^[multiply\\:#000):"..
				(x+i)..",0=W_".. n ..".png"..colorize

        i = i + 11
    end)
    ent:set_properties({ textures={texture} })

    if ent ~= nil then
        ent:set_attach(player, "", {x=0,y=20,z=0}, {x=0,y=0,z=0})
        nametags[player:get_player_name()] = ent
        ent = ent:get_luaentity()
        ent.wielder = player
    end
end

local function remove_tag(player)
	local tag = nametags[player:get_player_name()]
	if tag then
		tag:remove()
		nametags[player:get_player_name()] = nil
	end
end

local nametag = {
	initial_properties = {
	    physical = false,
	    collisionbox = {x=0, y=0, z=0},
	    visual = "sprite",
	    textures = {"blank.png"},
	    visual_size = {x=2.10, y=0.15, z=2.10},
    },
	on_activate = function(self, staticdata)
		if staticdata == "expired" then
			if self.wielder then
				remove_tag(self.wielder)
			else
				self.object:remove()
			end
		end
	end,
	get_staticdata = function()
		return "expired"
	end,
}

function nametag:on_step()
	local wielder = self.wielder
	local player_name = wielder:get_player_name()
	if wielder == nil then self.object:remove()
	elseif wielder and wielder:get_meta():get_string("is_spectator") == "true" then self.object:remove()
	elseif core.get_player_by_name(player_name) == nil then self.object:remove() end
end

core.register_entity(":playertag:tag", nametag)

local function step()
	for _, player in pairs(core.get_connected_players()) do
		if nametags[player:get_player_name()]:get_luaentity() == nil then
			add_tag(player)
		else
			nametags[player:get_player_name()]:set_attach(player, "", {x=0,y=20,z=0}, {x=0,y=0,z=0})
		end
	end

	core.after(5, step)
end

core.after(1, step)

core.register_on_joinplayer(function(player)
	player:set_nametag_attributes({
		color = {a = 0, r = 0, g = 0, b = 0}
	})
	add_tag(player)
end)

core.register_chatcommand("tag", {
	params = "<PlayerName> <color> <tag> | r <PlayerName>",
	privs = {server=true},
	func = function(_, param)
        local args = param:split(" ")
		if args[1] == "r" then
			if #args < 2 then
				return false, "Usage: /tag r <PlayerName>"
			end

			local player_name = args[2]
			local player = core.get_player_by_name(player_name)
			if not player then
				return false, "Player " .. player_name .. " is not online."
			end

			player:get_meta():set_string("tag", "")
			player:get_meta():set_string("tag_color", "")
			remove_tag(player)

			return true, "Tag successfully removed for player " .. player_name .. "."
		end

        if #args < 3 then
            return false, "Usage: /tag <PlayerName> <color> <tag>"
        end

        local player_name = args[1]
        local player = core.get_player_by_name(player_name)
		if not player then
			return false, "Player " .. player_name .. " is not online."
		end

		local color = args[2]
        local tag = param:sub(#player_name + #color + 3)
		player:get_meta():set_string("tag", tag)
		player:get_meta():set_string("tag_color", color)
		remove_tag(player)

        return true, "Tag successfully saved for player " .. player_name .. "."
	end,
})

core.register_on_leaveplayer(function(player)
	remove_tag(player)
end)
