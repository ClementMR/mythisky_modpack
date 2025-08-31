ms_items = {}

local modpath = core.get_modpath(core.get_current_modname())

local files = {
    "cooldown",
    "snowball",
    "multitool"
}

for _, file in ipairs(files) do
    dofile(modpath .. "/" .. file .. ".lua")
end