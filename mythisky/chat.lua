local S = core.get_translator(core.get_current_modname())

local minigame_api = core.global_exists("minigame")

core.override_chatcommand("pulverize", {
	privs = {creative=true},
})

core.override_chatcommand("clearinv", {
	privs = {creative=true},
})

local in_progress = {}
core.register_chatcommand("lobby", {
	description = S("Teleport the player to the lobby"),
	privs = {interact=true},
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then return end

		local pos = core.settings:get_pos("static_spawnpoint")
		if not pos then return end

		if minigame_api then
			local entry = minigame.get_player_entry(player)
			if entry and entry.game and entry.map then
				local game, map = minigame.get_gamedef_and_mapdef(entry.game, entry.map)
				local loading = minigame.get_map_information(game, map).loading

				if not loading then
					minigame.leave_game(player)

					core.sound_play("mythisky_teleportation", {pos=player:get_pos(), gain=1.0})

					return
				else
					return false, core.colorize("#F4320B", S("You are not allowed to leave the map while it's loading!"))
				end
			end
		end

		if in_progress[name] then
			return false, core.colorize("red", S("Teleportation already in progress!"))
		end

		hud_api.show_actionbar(player, S("Teleportation in progress..."), "0x43E8DA")

		in_progress[name] = core.after(3, function()
			player:set_pos(pos)
			core.sound_play("mythisky_teleportation", {pos=player:get_pos(), gain=1.0})

			hud_api.remove(player, "actionbar")
			in_progress[name] = nil
		end)
	end,
})

core.register_chatcommand("discord", {
	description = S("Show the Discord server link"),
	func = function(name)
		return true, S("Discord link:  @1", mythisky.DISCORD)
	end,
})