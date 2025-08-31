--- Registered armors.
--
--  @topic armor


-- support for i18n
local S = core.get_translator(core.get_current_modname())

--- Steel
--
--  Requires `armor_material_steel`.
--
--  @section steel


--- Steel Helmet
--
--  @helmet 3d_armor:helmet_steel
--  @img 3d_armor_inv_helmet_steel.png
--  @grp armor_head 1
--  @grp armor_heal 0
--  @grp armor_use 800
--  @armorgrp fleshy 10
--  @damagegrp cracky 2
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:helmet_steel", {
    description = S("Steel Helmet"),
    inventory_image = "3d_armor_inv_helmet_steel.png",
    groups = {armor_head=1, armor_heal=0, armor_use=800},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
--- Steel Chestplate
--
--  @chestplate 3d_armor:chestplate_steel
--  @img 3d_armor_inv_chestplate_steel.png
--  @grp armor_torso 1
--  @grp armor_heal 0
--  @grp armor_use 800
--  @armorgrp fleshy
--  @damagegrp cracky 2
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:chestplate_steel", {
    description = S("Steel Chestplate"),
    inventory_image = "3d_armor_inv_chestplate_steel.png",
    groups = {armor_torso=1, armor_heal=0, armor_use=800},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
--- Steel Leggings
--
--  @leggings 3d_armor:leggings_steel
--  @img 3d_armor_inv_leggings_steel.png
--  @grp armor_legs 1
--  @grp armor_heal 0
--  @grp armor_use 800
--  @armorgrp fleshy 15
--  @damagegrp cracky 2
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:leggings_steel", {
    description = S("Steel Leggings"),
    inventory_image = "3d_armor_inv_leggings_steel.png",
    groups = {armor_legs=1, armor_heal=0, armor_use=800},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
--- Steel Boots
--
--  @boots 3d_armor:boots_steel
--  @img 3d_armor_inv_boots_steel.png
--  @grp armor_feet 1
--  @grp armor_heal 0
--  @grp armor_use 800
--  @armorgrp fleshy 10
--  @damagegrp cracky 2
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:boots_steel", {
    description = S("Steel Boots"),
    inventory_image = "3d_armor_inv_boots_steel.png",
    groups = {armor_feet=1, armor_heal=0, armor_use=800},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
--- Steel Shield
--
--  @shield shields:shield_steel
--  @img shields_inv_shield_steel.png
--  @grp armor_shield 1
--  @grp armor_heal 0
--  @grp armor_use 800
--  @armorgrp fleshy 10
--  @damagegrp cracky 2
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor(":shields:shield_steel", {
    description = S("Steel Shield"),
    inventory_image = "shields_inv_shield_steel.png",
    groups = {armor_shield=1, armor_heal=0, armor_use=800},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
    reciprocate_damage = true,
    on_damage = function(player) armor:play_sound_effect(player, "default_dig_metal") end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_dug_metal") end,
})