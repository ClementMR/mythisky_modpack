-- Areas mod by ShadowNinja
-- Based on node_ownership
-- License: LGPLv2+

areas = {}

areas.modpath = core.get_modpath(core.get_current_modname())
dofile(areas.modpath.."/api.lua")

local async_dofile = core.register_async_dofile or dofile
async_dofile(areas.modpath.."/async.lua")

dofile(areas.modpath.."/internal.lua")
dofile(areas.modpath.."/chatcommands.lua")
dofile(areas.modpath.."/pos.lua")
dofile(areas.modpath.."/interact.lua")
dofile(areas.modpath.."/hud.lua")

areas:load()

core.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 then
        local pos = player:get_pos()
        local areas_at_pos = areas:getAreasAtPos(pos)

        if reason.type == "fall" and areas_at_pos and #areas_at_pos > 0 then
            return 0 -- Cancel fall damage
        end
    end

    return hp_change
end, true)