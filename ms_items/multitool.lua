local times = {[1]=0.3, [2]=0.3, [3]=0.3}

core.register_tool("ms_items:multitool", {
	description = "Multitool",
	inventory_image = "default_tool_diamondpick.png^[colorize:purple:125",
	range = 10,
	tool_capabilities = {
		full_punch_interval = 0,
		max_drop_level=0,
		groupcaps={
			cracky = {times=times, uses=0, maxlevel=4},
			crumbly = {times=times, uses=0, maxlevel=4},
			choppy = {times=times, uses=0, maxlevel=4},
			snappy = {times=times, uses=0, maxlevel=4},
			unbreakable = {times=times, uses=0, maxlevel=4}
		},
		damage_groups = {fleshy=1000},
	},
    on_drop = function() return end
})