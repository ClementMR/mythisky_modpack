local S = core.get_translator(core.get_current_modname())

local function switch_to(player, old_item, new_item)
	if player:get_player_control().RMB and player:get_player_control().sneak then
		local inv = player:get_inventory()
		-- Hotbar size
		for i = 1, 8 do
			local stack = inv:get_stack("main", i)
			if stack == old_item then
				inv:remove_item("main", stack)
				inv:set_stack("main", i, ItemStack(new_item))

				break
			end
		end
	end
end

local info = "\n" .. core.colorize("grey", S("(Sneak + Right-Click to switch to the next item)"))

core.register_tool("ms_arena:sword_stone", {
	description = ItemStack("default:sword_stone"):get_description() .. info,
	inventory_image = "default_tool_stonesword.png^ms_arena_infinite_item.png",
	wield_image = "default_tool_stonesword.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=0, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
	on_secondary_use = function(itemstack, user) switch_to(user, itemstack, "ms_arena:sword_steel") end,
	on_drop = function() return end
})

core.register_tool("ms_arena:sword_steel", {
	description = ItemStack("default:sword_steel"):get_description() .. info,
	inventory_image = "default_tool_steelsword.png^ms_arena_infinite_item.png",
	wield_image = "default_tool_steelsword.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=0, maxlevel=2},
		},
		damage_groups = {fleshy=6},
	},
	on_secondary_use = function(itemstack, user) switch_to(user, itemstack, "ms_arena:sword_bronze") end,
	on_drop = function() return end
})

core.register_tool("ms_arena:sword_bronze", {
	description = ItemStack("default:sword_bronze"):get_description() .. info,
	inventory_image = "default_tool_bronzesword.png^ms_arena_infinite_item.png",
	wield_image = "default_tool_bronzesword.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.75, [2]=1.30, [3]=0.375}, uses=0, maxlevel=2},
		},
		damage_groups = {fleshy=6},
	},
	on_secondary_use = function(itemstack, user) switch_to(user, itemstack, "ms_arena:sword_mese") end,
	on_drop = function() return end
})

core.register_tool("ms_arena:sword_mese", {
	description = ItemStack("default:sword_mese"):get_description() .. info,
	inventory_image = "default_tool_mesesword.png^ms_arena_infinite_item.png",
	wield_image = "default_tool_mesesword.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=0, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	},
	on_secondary_use = function(itemstack, user) switch_to(user, itemstack, "ms_arena:sword_diamond") end,
    on_drop = function() return end
})

core.register_tool("ms_arena:sword_diamond", {
	description = ItemStack("default:sword_diamond"):get_description() .. info,
	inventory_image = "default_tool_diamondsword.png^ms_arena_infinite_item.png",
	wield_image = "default_tool_diamondsword.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=0, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
	on_secondary_use = function(itemstack, user) switch_to(user, itemstack, "ms_arena:sword_stone") end,
    on_drop = function() return end
})

core.register_craftitem("ms_arena:apple", {
    description = ItemStack("default:apple"):get_description() .. info,
    inventory_image = "default_apple.png^ms_arena_infinite_item.png",
	wield_image = "default_apple.png",
    range = 0.0,
    stack_max = 1,
    on_use = core.item_eat(2, "ms_arena:apple"),
	on_secondary_use = function(itemstack, user) switch_to(user, itemstack, "ms_arena:bread") end,
    on_drop = function() return end
})

core.register_craftitem("ms_arena:bread", {
	description = ItemStack("farming:bread"):get_description() .. info,
	inventory_image = "farming_bread.png^ms_arena_infinite_item.png",
	wield_image = "farming_bread.png",
    range = 0.0,
    stack_max = 1,
	on_use = core.item_eat(5, "ms_arena:bread"),
	on_secondary_use = function(itemstack, user) switch_to(user, itemstack, "ms_arena:apple") end,
    on_drop = function() return end
})