-- This is inspired by the landrush mod by Bremaweb
local S = core.get_translator("ms_area")
areas.hud = {}
areas.hud.refresh = 0

core.register_globalstep(function(dtime)
	areas.hud.refresh = areas.hud.refresh + dtime
	if areas.hud.refresh > 1 then
		areas.hud.refresh = 0
	else
		return
	end

	for _, player in pairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local pos = vector.round(player:get_pos())

		if not core.check_player_privs(name, {protection_bypass = true}) then
			local hud = areas.hud[name]
			if hud and hud.areasId then
				player:hud_remove(hud.areasId)
				areas.hud[name] = nil
			end
			return
		end

		pos = vector.apply(pos, function(p)
			return math.max(math.min(p, 2147483), -2147483)
		end)

		local areaStrings = {}
		for id, area in pairs(areas:getAreasAtPos(pos)) do
			table.insert(areaStrings, ("%s [%u] (%s)")
					:format(area.name, id, area.owner))
		end

		for i, area in pairs(areas:getExternalHudEntries(pos)) do
			local str = ""
			if area.name then str = area.name .. " " end
			if area.id then str = str.."["..area.id.."] " end
			if area.owner then str = str.."("..area.owner..")" end
			table.insert(areaStrings, str)
		end

		local areaString = S("Areas:")
		if #areaStrings > 0 then
			areaString = areaString.."\n"..
				table.concat(areaStrings, "\n")
		end
		local hud = areas.hud[name]
		if not hud then
			hud = {}
			areas.hud[name] = hud
			hud.areasId = player:hud_add({
				[core.features.hud_def_type_field and "type" or "hud_elem_type"] = "text", -- compatible with older versions
				name = "Areas",
				number = 0x000000,
				position = {x=0, y=1},
				offset = {x=8, y=-8},
				text = areaString,
				scale = {x=200, y=60},
				alignment = {x=1, y=-1},
			})
			hud.oldAreas = areaString
			return
		elseif hud.oldAreas ~= areaString then
			player:hud_change(hud.areasId, "text", areaString)
			hud.oldAreas = areaString
		end
	end
end)

core.register_on_leaveplayer(function(player)
	areas.hud[player:get_player_name()] = nil
end)
