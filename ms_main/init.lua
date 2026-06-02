skylith = {}

skylith.DEATH_LAYER    = ms_utils.number_or(core.settings:get("death_layer"), -100)
skylith.TIPS           = ms_utils.number_or(core.settings:get("tips_timer"), 600)

local modpath = core.get_modpath(core.get_current_modname())

local files = {
    "callbacks",
    "clear_recipes",
    "functions",
    "inventory",
    "nodes",
    "tips",
}

for _, file in ipairs(files) do
    dofile(modpath .. "/" .. file .. ".lua")
end