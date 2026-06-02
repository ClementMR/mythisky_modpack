ms_utils = {}

local modpath = core.get_modpath(core.get_current_modname())

local files = {
    "base",
    "chat",
    "player",
}

for _, file in ipairs(files) do
    dofile(modpath .. "/" .. file .. ".lua")
end
