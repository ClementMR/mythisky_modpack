local function get_player_name(player)
	if type(player) == "string" then
		return player
	elseif type(player) == "userdata" and player:is_player() then
		return player:get_player_name()
	end
end

function ms_items.cooldown()
	return {
		players = {},
		set = function(self, player, time)
			local pname = get_player_name(player)
			if not pname then
				return
			end

			-- S'il y a un cooldown en cours, on l'annule
			if self.players[pname] then
				self.players[pname]:cancel()

				if not time then
					self.players[pname] = nil
					return
				end
			end

			self.players[pname] = core.after(time, function() self.players[pname] = nil end)
		end,
		get = function(self, player)
			local pname = get_player_name(player)
			return pname and self.players[pname]
		end
	}
end