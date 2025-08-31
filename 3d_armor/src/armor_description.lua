local S = core.get_translator(core.get_current_modname())

local pieces = {
    "3d_armor:helmet_",
    "3d_armor:chestplate_",
    "3d_armor:leggings_",
    "3d_armor:boots_",
    "shields:shield_"
}

for k, _ in pairs(armor.materials) do
    for _, piece in pairs(pieces) do
        local item = piece .. k
        local def = core.registered_tools[item]
        local protection = def.armor_groups.fleshy or 0
        local healing = def.groups.armor_heal or 0
        local new_desc = def.description .. "\n" ..
            core.colorize("grey", S("Armor Protection: @1", protection) ..
            "\n" .. S("Armor Healing: @1", healing))

        core.override_item(item, {description = new_desc})
    end
end