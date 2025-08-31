--- Registered armors.
--
--  @topic armor


-- support for i18n
local S = core.get_translator(core.get_current_modname())

--- Wood
--
--  Requires `armor_material_wood`.
--
--  @section wood


--- Wood Helmet
--
--  @helmet 3d_armor:helmet_wood
--  @img 3d_armor_inv_helmet_wood.png
--  @grp armor_head 1
--  @grp armor_heal 0
--  @grp armor_use 2000
--  @grp flammable 1
--  @armorgrp fleshy 5
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 3
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:helmet_wood", {
    description = S("Wood Helmet"),
    inventory_image = "3d_armor_inv_helmet_wood.png",
    groups = {armor_head=1, armor_heal=0, armor_use=2000, flammable=1},
    armor_groups = {fleshy=5},
    damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
})
--- Wood Chestplate
--
--  @chestplate 3d_armor:chestplate_wood
--  @img 3d_armor_inv_chestplate_wood.png
--  @grp armor_torso 1
--  @grp armor_heal 0
--  @grp armor_use 2000
--  @grp flammable 1
--  @armorgrp fleshy 10
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 3
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:chestplate_wood", {
    description = S("Wood Chestplate"),
    inventory_image = "3d_armor_inv_chestplate_wood.png",
    groups = {armor_torso=1, armor_heal=0, armor_use=2000, flammable=1},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
})
--- Wood Leggings
--
--  @leggings 3d_armor:leggings_wood
--  @img 3d_armor_inv_leggings_wood.png
--  @grp armor_legs 1
--  @grp armor_heal 0
--  @grp armor_use 1000
--  @grp flammable 1
--  @armorgrp fleshy 10
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 3
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:leggings_wood", {
    description = S("Wood Leggings"),
    inventory_image = "3d_armor_inv_leggings_wood.png",
    groups = {armor_legs=1, armor_heal=0, armor_use=2000, flammable=1},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
})
--- Wood Boots
--
--  @boots 3d_armor:boots_wood
--  @img 3d_armor_inv_boots_wood.png
--  @grp armor_feet 1
--  @grp armor_heal 0
--  @grp armor_use 2000
--  @grp flammable 1
--  @armorgrp fleshy 5
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 3
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:boots_wood", {
    description = S("Wood Boots"),
    inventory_image = "3d_armor_inv_boots_wood.png",
    armor_groups = {fleshy=5},
    damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
    groups = {armor_feet=1, armor_heal=0, armor_use=2000, flammable=1},
})
--- Wood Shield
--
--  @shield shields:shield_wood
--  @img shields_inv_shield_wood.png
--  @grp armor_shield 1
--  @grp armor_heal 0
--  @grp armor_use 2000
--  @grp flammable 1
--  @armorgrp fleshy 5
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 3
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor(":shields:shield_wood", {
    description = S("Wooden Shield"),
    inventory_image = "shields_inv_shield_wood.png",
    groups = {armor_shield=1, armor_heal=0, armor_use=2000, flammable=1},
    armor_groups = {fleshy=5},
    damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
    reciprocate_damage = true,
    on_damage = function(player) armor:play_sound_effect(player, "default_wood_footstep") end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_wood_footstep") end,
})
--- Enhanced Wood Shield
--
--  @shield shields:shield_enhanced_wood
--  @img shields_inv_shield_enhanced_wood.png
--  @grp armor_shield 1
--  @grp armor_heal 0
--  @grp armor_use 2000
--  @armorgrp fleshy 8
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 3
--  @damagegrp crumbly 2
--  @damagegrp level 2
armor:register_armor(":shields:shield_enhanced_wood", {
    description = S("Enhanced Wood Shield"),
    inventory_image = "shields_inv_shield_enhanced_wood.png",
    groups = {armor_shield=1, armor_heal=0, armor_use=2000},
    armor_groups = {fleshy=8},
    damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=2},
    reciprocate_damage = true,
    on_damage = function(player) armor:play_sound_effect(player, "default_dig_metal") end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_dug_metal") end,
})

core.register_craft({
    output = "shields:shield_enhanced_wood",
    recipe = {
        {"default:steel_ingot"},
        {"shields:shield_wood"},
        {"default:steel_ingot"},
    },
})

core.register_craft({
    type = "fuel",
    recipe = "shields:shield_wood",
    burntime = 8,
})

local wood_armor_fuel = {
    helmet = 6,
    chestplate = 8,
    leggings = 7,
    boots = 5
}

for armor, burn in pairs(wood_armor_fuel) do
    core.register_craft({
        type = "fuel",
        recipe = "3d_armor:" .. armor .. "_wood",
        burntime = burn,
    })
end