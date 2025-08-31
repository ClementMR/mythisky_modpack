local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local last_punch_time = {}
local timer = 0

dofile(modpath.."/api.lua")

-- local functions
local S = core.get_translator(core.get_current_modname())

-- Load Configuration

for name, config in pairs(armor.config) do
	local setting = core.settings:get("armor_"..name)
	if type(config) == "number" then
		setting = tonumber(setting)
	elseif type(config) == "string" then
		setting = tostring(setting)
	elseif type(config) == "boolean" then
		setting = core.settings:get_bool("armor_"..name)
	end
	if setting ~= nil then
		armor.config[name] = setting
	end
end
for material, _ in pairs(armor.materials) do
	local key = "material_"..material
	if armor.config[key] == false then
		armor.materials[material] = nil
	end
end

-- Convert set_elements to a Lua table splitting on blank spaces
local t_set_elements = armor.config.set_elements
armor.config.set_elements = string.split(t_set_elements, " ")

-- Remove torch damage if fire_protect_torch == false
if armor.config.fire_protect_torch == false and armor.config.fire_protect == true then
	for k,v in pairs(armor.fire_nodes) do
		for k2,v2 in pairs(v) do
			if string.find (v2,"torch") then
				armor.fire_nodes[k] = nil
			end
		end
	end
end

-- Mod Compatibility

if core.get_modpath("technic") then
	armor:register_armor_group("radiation")
end



-- Armor Initialization

armor:register_on_damage(function(player, index, stack)
	local name = player:get_player_name()
	local def = stack:get_definition()
	if name and def and def.description and stack:get_wear() > 60100 then
		core.chat_send_player(name, S("Your @1 is almost broken!", def.description))
		core.sound_play("default_tool_breaks", {to_player = name, gain = 2.0})
	end
end)
armor:register_on_destroy(function(player, index, stack)
	local name = player:get_player_name()
	local def = stack:get_definition()
	if name and def and def.description then
		core.chat_send_player(name, S("Your @1 got destroyed!", def.description))
		core.sound_play("default_tool_breaks", {to_player = name, gain = 2.0})
	end
end)

local function validate_armor_inventory(player)
	-- Workaround for detached inventory swap exploit
	local _, inv = armor:get_valid_player(player, "[validate_armor_inventory]")
	local pos = player:get_pos()
	if not inv then
		return
	end
	local armor_prev = {}
	local attribute_meta = player:get_meta() -- I know, the function's name is weird but let it be like that. ;)
	local armor_list_string = attribute_meta:get_string("3d_armor_inventory")
	if armor_list_string then
		local armor_list = armor:deserialize_inventory_list(armor_list_string)
		for i, stack in ipairs(armor_list) do
			if stack:get_count() > 0 then
				armor_prev[stack:get_name()] = i
			end
		end
	end
	local elements = {}
	local player_inv = player:get_inventory()
	for i = 1, #armor.elements do
		local stack = inv:get_stack("armor", i)
		if stack:get_count() > 0 then
			local item = stack:get_name()
			local element = armor:get_element(item)
			if element and not elements[element] then
				if armor_prev[item] then
					armor_prev[item] = nil
				else
					-- Item was not in previous inventory
					armor:run_callbacks("on_equip", player, i, stack)
				end
				elements[element] = true;
			else
				inv:remove_item("armor", stack)
				core.item_drop(stack, player, pos)
				-- The following code returns invalid items to the player's main
				-- inventory but could open up the possibity for a hacked client
				-- to receive items back they never really had. I am not certain
				-- so remove the is_singleplayer check at your own risk :]
				if core.is_singleplayer() and player_inv and
					player_inv:room_for_item("main", stack) then
					player_inv:add_item("main", stack)
				end
			end
		end
	end
	for item, i in pairs(armor_prev) do
		local stack = ItemStack(item)
		-- Previous item is not in current inventory
		armor:run_callbacks("on_unequip", player, i, stack)
	end
end

local function init_player_armor(initplayer)
	local name = assert(initplayer:get_player_name())
	local armor_inv = core.create_detached_inventory(name.."_armor", {
		on_put = function(inv, listname, index, stack, player)
			validate_armor_inventory(player)
			armor:save_armor_inventory(player)
			armor:set_player_armor(player)

			if core.get_modpath("sfinv") then
				sfinv.set_page(player, "sfinv:crafting")
			else
				armor:show_formspec(player:get_player_name())
			end
		end,
		on_take = function(inv, listname, index, stack, player)
			validate_armor_inventory(player)
			armor:save_armor_inventory(player)
			armor:set_player_armor(player)

			if core.get_modpath("sfinv") then
				sfinv.set_page(player, "sfinv:crafting")
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			validate_armor_inventory(player)
			armor:save_armor_inventory(player)
			armor:set_player_armor(player)

			if core.get_modpath("sfinv") then
				sfinv.set_page(player, "sfinv:crafting")
			end
		end,
		allow_put = function(inv, listname, index, put_stack, player)
			if player:get_player_name() ~= name then
				return 0
			end

			local element = armor:get_element(put_stack:get_name())
			if not element then
				return 0
			end

			local valid_index = {head = 1, torso = 2, legs = 3, feet = 4, shield = 5}
			if valid_index[element] ~= index then
				return 0
			end

			return 1
		end,
		allow_take = function(inv, listname, index, stack, player)
			if player:get_player_name() ~= name then
				return 0
			end

			return stack:get_count()
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if player:get_player_name() ~= name then
				return 0
			end

			local stack = inv:get_stack(from_list, from_index)
			if stack:is_empty() then
				return 0
			end

			local element = armor:get_element(stack:get_name())
			if not element then
				return 0
			end

			local valid_index = {head = 1, torso = 2, legs = 3, feet = 4, shield = 5}
			if valid_index[element] ~= to_index then
				return 0
			end

			return count
		end,
	}, name)
	armor_inv:set_size("armor", #armor.elements)
	if not armor:load_armor_inventory(initplayer) and armor.migrate_old_inventory then
		local player_inv = initplayer:get_inventory()
		player_inv:set_size("armor", #armor.elements)
		for i=1, 6 do
			local stack = player_inv:get_stack("armor", i)
			armor_inv:set_stack("armor", i, stack)
		end
		armor:save_armor_inventory(initplayer)
		player_inv:set_size("armor", 0)
	end
	for i=1, #armor.elements do
		local stack = armor_inv:get_stack("armor", i)
		if stack:get_count() > 0 then
			armor:run_callbacks("on_equip", initplayer, i, stack)
		end
	end
	armor.def[name] = {
		level = 0,
		state = 0,
		count = 0,
		groups = {},
	}
	for _, phys in pairs(armor.physics) do
		armor.def[name][phys] = 1
	end
	for _, attr in pairs(armor.attributes) do
		armor.def[name][attr] = 0
	end
	for group, _ in pairs(armor.registered_groups) do
		armor.def[name].groups[group] = 0
	end
	local skin = armor.default_skin..".png"
	armor.textures[name] = {
		skin = skin,
		armor = "blank.png",
		wielditem = "blank.png",
	}
	armor:set_player_armor(initplayer)

	if core.get_modpath("sfinv") then
		sfinv.set_page(initplayer, "sfinv:crafting")
	end
end

-- Armor Player Model
player_api.register_model("3d_armor_character.b3d", {
	animation_speed = 30,
	textures = {
		armor.default_skin..".png",
		"blank.png",
		"blank.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166, eye_height = 0.3, override_local = true,
		collisionbox = {-0.6, 0.0, -0.6, 0.6, 0.3, 0.6}},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160, eye_height = 0.8, override_local = true,
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.0, 0.3}},
		-- compatibility w/ the emote mod
		wave = {x = 192, y = 196, override_local = true},
		point = {x = 196, y = 196, override_local = true},
		freeze = {x = 205, y = 205, override_local = true},
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	-- stepheight: use default
	eye_height = 1.47,
})

core.register_on_player_receive_fields(function(player, formname, fields)
	local name = armor:get_valid_player(player, "[on_player_receive_fields]")
	if not name then
		return
	end
	local player_name = player:get_player_name()
	for field, _ in pairs(fields) do
		if string.find(field, "skins_set") then
			armor:update_skin(player_name)
		end
	end
end)

core.register_on_joinplayer(function(player)
	player_api.set_model(player, "3d_armor_character.b3d")
	init_player_armor(player)
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if name then
		armor.def[name] = nil
		armor.textures[name] = nil
	end
end)

if armor.config.drop == true or armor.config.destroy == true then
	core.register_on_dieplayer(function(player)
		local name, armor_inv = armor:get_valid_player(player, "[on_dieplayer]")
		if not name then return end

		if core.is_creative_enabled(player:get_player_name()) then return end

		local drop = {}
		for i=1, armor_inv:get_size("armor") do
			local stack = armor_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				--soulbound armors remain equipped after death
				if core.get_item_group(stack:get_name(), "soulbound") == 0 then
					table.insert(drop, stack)
					armor:run_callbacks("on_unequip", player, i, stack)
					armor_inv:set_stack("armor", i, nil)
				end
			end
		end
		armor:save_armor_inventory(player)
		armor:set_player_armor(player)
		local pos = player:get_pos()
		if pos then
			for _,stack in ipairs(drop) do
				armor.drop_armor(pos, stack)
			end
		end
	end)

	core.register_on_respawnplayer(function(player)
		-- reset un-dropped armor and it's effects
		armor:set_player_armor(player)

		if core.get_modpath("sfinv") then
			sfinv.set_page(player, "sfinv:crafting")
		end
	end)
end

if armor.config.punch_damage == true then
	core.register_on_punchplayer(function(player, hitter,
			time_from_last_punch, tool_capabilities)
		local name = player:get_player_name()
		if hitter then
			local hit_ip = hitter:is_player()
			if name and hit_ip and core.is_protected(player:get_pos(), "") then
				return
			end
		end

		if name then
			armor:punch(player, hitter, time_from_last_punch, tool_capabilities)
			last_punch_time[name] = core.get_gametime()
		end
	end)
end

core.register_on_player_hpchange(function(player, hp_change, reason)
	if not core.is_player(player) then
		return hp_change
	end

	--if hp_change <= 20 then return hp_change end

	if reason.type == "drown" or reason.hunger or hp_change >= 0 then
		return hp_change
	end

	local name = player:get_player_name()
	local properties = player:get_properties()
	local hp = player:get_hp()
	if hp + hp_change < properties.hp_max then
		local heal = armor.def[name].heal
		if heal >= math.random(100) then
			hp_change = 0
		end
		-- check if armor damage was handled by fire or on_punchplayer
		local time = last_punch_time[name] or 0
		if time == 0 or time + 1 < core.get_gametime() then
			armor:punch(player)
		end
	end

	return hp_change
end, true)

if core.get_modpath("sfinv") then
	local orig_get = sfinv.pages["sfinv:crafting"].get
	sfinv.override_page("sfinv:crafting", {
		get = function(self, player, context)
			local form = armor:get_armor_formspec(player:get_player_name())
			return orig_get(self, player, context) .. form
		end
	})
end

core.register_globalstep(function(dtime)
	timer = timer + dtime

	if armor.config.feather_fall == true then
		for _,player in pairs(core.get_connected_players()) do
			local name = player:get_player_name()
			if armor.def[name].feather > 0 then
				local vel_y = player:get_velocity().y
				if vel_y < -0.5 then
					vel_y = -(vel_y * 0.05)
					player:add_velocity({x = 0, y = vel_y, z = 0})
				end
			end
		end
	end

	if timer <= armor.config.init_delay then
		return
	end
	timer = 0

	-- water breathing protection, added by TenPlus1
	if armor.config.water_protect == true then
		for _,player in pairs(core.get_connected_players()) do
			local name = player:get_player_name()
			if armor.def[name].water > 0 and
					player:get_breath() < 10 then
				player:set_breath(10)
			end
		end
	end
end)

if armor.config.fire_protect == true then

	-- make torches hurt
	core.override_item("default:torch", {damage_per_second = 1})
	core.override_item("default:torch_wall", {damage_per_second = 1})
	core.override_item("default:torch_ceiling", {damage_per_second = 1})

	-- check player damage for any hot nodes we may be protected against
	core.register_on_player_hpchange(function(player, hp_change, reason)

		if reason.type == "node_damage" and reason.node then
			-- fire protection
			if armor.config.fire_protect == true and hp_change < 0 then
				local name = player:get_player_name()
				for _,igniter in pairs(armor.fire_nodes) do
					if reason.node == igniter[1] then
						if armor.def[name].fire >= igniter[2] then
							hp_change = 0
						end
					end
				end
			end
		end
		return hp_change
	end, true)
end

-- Register armors
for k, _ in pairs(armor.materials) do
	if armor.config["material_" .. k] then
		dofile(core.get_modpath(core.get_current_modname()).."/src/"..k.."_armor.lua")
	end
end

dofile(core.get_modpath(core.get_current_modname()).."/src/admin_armor.lua")
dofile(core.get_modpath(core.get_current_modname()).."/src/armor_description.lua")
dofile(core.get_modpath(core.get_current_modname()).."/src/recipes.lua")
dofile(core.get_modpath(core.get_current_modname()).."/src/aliases.lua")