local S = core.get_translator(core.get_current_modname())

local edit_skin_enabled = core.global_exists("edit_skin")
local ms_settings_enabled = core.global_exists("ms_settings")

if core.get_modpath("sfinv") then
	local orig_get = sfinv.pages["sfinv:crafting"].get
	sfinv.override_page("sfinv:crafting", {
		get = function(self, player, context)
			local form = [[
				style_type[box;noclip=true]
				box[8.5,-0.3;1.2,9.8;#3B3B3B]
			]]

			if edit_skin_enabled then
				form = form .. "style[btn_edit_skin;bgcolor=#67C447]" ..
				"image_button[8.7,0;1,1;mythisky_hanger.png;btn_edit_skin;;true;]" ..
					"tooltip[btn_edit_skin;"..S("Edit your skin").."]"
			end

			if ms_settings_enabled then
				form = form .. "image_button[8.7,1.2;1,1;settings_btn.png;btn_settings;;true;false]" ..
					"tooltip[btn_settings;"..S("Change your settings").."]"
			end

			return orig_get(self, player, context) .. form
		end
	})

	core.register_on_player_receive_fields(function(player, _, fields)
		if fields.btn_edit_skin then
			edit_skin.show_formspec(player)
		elseif fields.btn_settings then
			ms_settings.show_settings(player:get_player_name(), ms_settings.categories[1]:lower())
		end
	end)
end