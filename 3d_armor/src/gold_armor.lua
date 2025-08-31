--- Registered armors.
--
--  @topic armor


local S = core.get_translator(core.get_current_modname())

--- Gold
--
--  Requires `armor_material_gold`.
--
--  @section gold


--- Gold Helmet
--
--  @helmet 3d_armor:helmet_gold
--  @img 3d_armor_inv_helmet_gold.png
--  @grp armor_head 1
--  @grp armor_heal 6
--  @grp armor_use 300
--  @armorgrp fleshy 10
--  @damagegrp cracky 1
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 3
--  @damagegrp level 2
armor:register_armor("3d_armor:helmet_gold", {
    description = S("Gold Helmet"),
    inventory_image = "3d_armor_inv_helmet_gold.png",
    groups = {armor_head=1, armor_heal=6, armor_use=300},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})
--- Gold Chestplate
--
--  @chestplate 3d_armor:chestplate_gold
--  @img 3d_armor_inv_chestplate_gold.png
--  @grp armor_torso 1
--  @grp armor_heal 6
--  @grp armor_use 300
--  @armorgrp fleshy 15
--  @damagegrp cracky 1
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 3
--  @damagegrp level 2
armor:register_armor("3d_armor:chestplate_gold", {
    description = S("Gold Chestplate"),
    inventory_image = "3d_armor_inv_chestplate_gold.png",
    groups = {armor_torso=1, armor_heal=6, armor_use=300},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})
--- Gold Leggings
--
--  @leggings 3d_armor:leggings_gold
--  @img 3d_armor_inv_leggings_gold.png
--  @grp armor_legs 1
--  @grp armor_heal 6
--  @grp armor_use 300
--  @armorgrp fleshy 15
--  @damagegrp cracky 1
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 3
--  @damagegrp level 2
armor:register_armor("3d_armor:leggings_gold", {
    description = S("Gold Leggings"),
    inventory_image = "3d_armor_inv_leggings_gold.png",
    groups = {armor_legs=1, armor_heal=6, armor_use=300},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})
--- Gold Boots
--
--  @boots 3d_armor:boots_gold
--  @img 3d_armor_inv_boots_gold.png
--  @grp armor_feet 1
--  @grp armor_heal 6
--  @grp armor_use 300
--  @armorgrp fleshy 10
--  @damagegrp cracky 1
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 3
--  @damagegrp level 2
armor:register_armor("3d_armor:boots_gold", {
    description = S("Gold Boots"),
    inventory_image = "3d_armor_inv_boots_gold.png",
    groups = {armor_feet=1, armor_heal=6, armor_use=300},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})
--- Gold Shield
--
--  @shield shields:shield_gold
--  @img shields_inv_shield_gold.png
--  @grp armor_shield 1
--  @grp armor_heal 6
--  @grp armor_use 300
--  @armorgrp fleshy 10
--  @damagegrp cracky 1
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 3
--  @damagegrp level 2
armor:register_armor(":shields:shield_gold", {
    description = S("Gold Shield"),
    inventory_image = "shields_inv_shield_gold.png",
    groups = {armor_shield=1, armor_heal=6, armor_use=300},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
    reciprocate_damage = true,
    on_damage = function(player) armor:play_sound_effect(player, "default_dig_metal") end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_dug_metal") end,
})