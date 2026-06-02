local PORTAL_DESTINATION = core.settings:get_pos("portal_destination")

core.register_node("ms_portal:portal", {
	description = "Portal",
	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		{
			name = "ms_portal_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.9,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "colorfacedir",
	palette = "ms_portal_portal_palette.png",
	post_effect_color = {a = 160, r = 50, g = 0, b = 160},
	sunlight_propagates = true,
	use_texture_alpha = "blend",
	walkable = false,
	pointable = false,
	is_ground_content = false,
	light_source = 7,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	drop = "",
})

local timer
core.register_globalstep(function(dtime)
    timer = (timer or 0) + dtime
    if timer > 1 then
		timer = 0
        for _, player in pairs(core.get_connected_players()) do
			local name = player:get_player_name()
            if core.get_node(player:get_pos()).name == "ms_portal:portal" then
				if core.global_exists("ffa") and not core.get_player_privs(name).ffa_manager then
					ffa.on_enter(player)
				elseif PORTAL_DESTINATION then
					player:set_pos(PORTAL_DESTINATION)
				end
            end
        end
    end
end)