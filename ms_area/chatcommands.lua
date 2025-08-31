local S = core.get_translator("ms_area")

core.register_chatcommand("protect", {
	params = S("<AreaName>"),
	description = S("Protect your own area"),
	privs = {protection_bypass=true},
	func = function(name, param)
		if param == "" then
			return false, S("Invalid usage, see /help @1.", "protect")
		end
		local pos1, pos2 = areas:getPos(name)
		if not (pos1 and pos2) then
			return false, S("You need to select an area first.")
		end

		core.log("action", "/protect invoked, owner="..name..
				" AreaName="..param..
				" StartPos="..core.pos_to_string(pos1)..
				" EndPos="  ..core.pos_to_string(pos2))

		local id = areas:add(name, param, pos1, pos2, nil)
		areas:save()

		return true, S("Area protected. ID: @1", id)
	end
})

core.register_chatcommand("add_owner", {
	params = S("<ParentID>").." "..S("<PlayerName>").." "..S("<AreaName>"),
	description = "Give a player access to a sub-area between two"
		.." positions that have already been protected.",
	privs = {protection_bypass=true},
	func = function(name, param)
		local pid, ownerName, areaName = param:match('^(%d+) ([^ ]+) (.+)$')

		if not pid then
			core.chat_send_player(name, S("Invalid usage, see /help @1.", "add_owner"))
			return
		end

		local pos1, pos2 = areas:getPos(name)
		if not (pos1 and pos2) then
			return false, S("You need to select an area first.")
		end

		if not areas:player_exists(ownerName) then
			return false, S("The player \"@1\" does not exist.", ownerName)
		end

		core.log("action", name.." runs /add_owner. Owner = "..ownerName..
				" AreaName = "..areaName.." ParentID = "..pid..
				" StartPos = "..pos1.x..","..pos1.y..","..pos1.z..
				" EndPos = "  ..pos2.x..","..pos2.y..","..pos2.z)

		-- Check if this new area is inside an area owned by the player
		pid = tonumber(pid)
		if (not areas:isAreaOwner(pid, name)) or
		   (not areas:isSubarea(pos1, pos2, pid)) then
			return false, S("You can't protect that area.")
		end

		local id = areas:add(ownerName, areaName, pos1, pos2, pid)
		areas:save()

		core.chat_send_player(ownerName,
				S("You have been granted control over area #@1. "..
				"Type /list_areas to show your areas.", id))
		return true, S("Area protected. ID: @1", id)
	end
})

core.register_chatcommand("rename_area", {
	params = S("<ID>").." "..S("<newName>"),
	description = S("Rename an area that you own"),
	privs = {protection_bypass=true},
	func = function(name, param)
		local id, newName = param:match("^(%d+)%s(.+)$")
		if not id then
			return false, S("Invalid usage, see /help @1.", "rename_area")
		end

		id = tonumber(id)
		if not id then
			return false, S("That area doesn't exist.")
		end

		if not areas:isAreaOwner(id, name) then
			return true, S("You don't own that area.")
		end

		areas.areas[id].name = newName
		areas:save()
		return true, S("Area renamed.")
	end
})

core.register_chatcommand("list_areas", {
	description = "List all areas",
	privs = {protection_bypass=true},
	func = function()
		local areaStrings = {}
		local indices = {}
		local counts = {} -- { [1] = name, [2] = count }, ...
		for _, area in pairs(areas.areas) do
			local i = indices[area.owner]
			if i then
				counts[i][2] = counts[i][2] + 1
			else
				table.insert(counts, { area.owner, 1 })
				indices[area.owner] = #counts
			end
		end
		-- Alphabatical name sorting
		table.sort(counts, function (kv_a, kv_b)
			return kv_a[1] < kv_b[1]
		end)
		--  Output
		for _, kv in ipairs(counts) do
			table.insert(areaStrings, S("@1 : @2 area(s)", kv[1], kv[2]))
		end
		if #areaStrings == 0 then
			return true, S("No visible areas.")
		end
		return true, table.concat(areaStrings, "\n")
	end
})

core.register_chatcommand("area_open", {
	params = S("<ID>"),
	description = S("Toggle an area open (anyone can interact) or closed"),
	privs = {protection_bypass=true},
	func = function(name, param)
		local id = tonumber(param)
		if not id then
			return false, S("Invalid usage, see /help @1.", "area_open")
		end

		if not areas:isAreaOwner(id, name) then
			return false, S("Area @1 does not exist"
					.." or is not owned by you.", id)
		end
		local open = not areas.areas[id].open
		-- Save false as nil to avoid inflating the DB.
		areas.areas[id].open = open or nil
		areas:save()
		return true, open and S("Area opened.") or S("Area closed.")
	end
})

core.register_chatcommand("remove_area", {
	params = S("<ID>"),
	description = S("Remove an area using an ID"),
	privs = {protection_bypass=true},
	func = function(name, param)
		local id = tonumber(param)
		if not id then
			return false, S("Invalid usage, see /help @1.", "remove_area")
		end

		if not areas:isAreaOwner(id, name) then
			return false, S("Area @1 does not exist or"
					.." is not owned by you.", id)
		end

		areas:remove(id)
		areas:save()
		return true, S("Removed area @1", id)
	end
})

core.register_chatcommand("move_area", {
	params = S("<ID>"),
	description = S("Move (or resize) an area to the current positions."),
	privs = {protection_bypass=true},
	func = function(name, param)
		local id = tonumber(param)
		if not id then
			return false, S("Invalid usage, see /help @1.", "move_area")
		end

		local area = areas.areas[id]
		if not area then
			return false, S("Area does not exist.")
		end

		local pos1, pos2 = areas:getPos(name)
		if not pos1 then
			return false, S("You need to select an area first.")
		end

		areas:move(id, area, pos1, pos2)
		areas:save()

		return true, S("Area successfully moved.")
	end,
})