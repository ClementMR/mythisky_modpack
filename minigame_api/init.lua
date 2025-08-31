local modpath = core.get_modpath(core.get_current_modname())

local files = {
    "api",
    "callbacks",
    "chatcommands"
}

for _, file in ipairs(files) do
    dofile(modpath .. "/" .. file .. ".lua")
end

core.register_node(":minigame:barrier", {
    description = "Barrier",
	inventory_image = "default_glass.png^[multiply:#FF0000",
	drawtype = "airlike",
	is_ground_content = false,
    pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1},
	on_blast = function() return end,
    on_drop = function() return end
})

core.register_alias("barrier", "minigame:barrier")