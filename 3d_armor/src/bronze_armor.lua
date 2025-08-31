--- Registered armors.
--
--  @topic armor


local S = core.get_translator(core.get_current_modname())

--- Bronze
--
--  Requires `armor_material_bronze`.
--
--  @section bronze


--- Bronze Helmet
--
--  @helmet 3d_armor:helmet_bronze
--  @img 3d_armor_inv_helmet_bronze.png
--  @grp armor_head 1
--  @grp armor_heal 6
--  @grp armor_use 400
--  @armorgrp fleshy 10
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:helmet_bronze", {
    description = S("Bronze Helmet"),
    inventory_image = "3d_armor_inv_helmet_bronze.png",
    groups = {armor_head=1, armor_heal=6, armor_use=400},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
})
--- Bronze Chestplate
--
--  @chestplate 3d_armor:chestplate_bronze
--  @img 3d_armor_inv_chestplate_bronze.png
--  @grp armor_torso 1
--  @grp armor_heal 6
--  @grp armor_use 400
--  @armorgrp fleshy 15
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:chestplate_bronze", {
    description = S("Bronze Chestplate"),
    inventory_image = "3d_armor_inv_chestplate_bronze.png",
    groups = {armor_torso=1, armor_heal=6, armor_use=400},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
})
--- Bronze Leggings
--
--  @leggings 3d_armor:leggings_bronze
--  @img 3d_armor_inv_leggings_bronze.png
--  @grp armor_legs 1
--  @grp armor_heal 6
--  @grp armor_use 400
--  @armorgrp fleshy 15
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:leggings_bronze", {
    description = S("Bronze Leggings"),
    inventory_image = "3d_armor_inv_leggings_bronze.png",
    groups = {armor_legs=1, armor_heal=6, armor_use=400},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
})
--- Bronze Boots
--
--  @boots 3d_armor:boots_bronze
--  @img 3d_armor_inv_boots_bronze.png
--  @grp armor_feet 1
--  @grp armor_heal 6
--  @grp armor_use 400
--  @armorgrp fleshy 10
--  @damagegrp cracky 3
--  @damagegrp snappy 2
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor("3d_armor:boots_bronze", {
    description = S("Bronze Boots"),
    inventory_image = "3d_armor_inv_boots_bronze.png",
    groups = {armor_feet=1, armor_heal=6, armor_use=400},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
})
--- Bronze Shield
--
--  @shield shields:shield_bronze
--  @img shields_inv_shield_bronze.png
--  @grp armor_shield 1
--  @grp armor_heal 6
--  @grp armor_use 400
--  @armorgrp fleshy 10
--  @damagegrp cracky 2
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 1
--  @damagegrp level 2
armor:register_armor(":shields:shield_bronze", {
    description = S("Bronze Shield"),
    inventory_image = "shields_inv_shield_bronze.png",
    groups = {armor_shield=1, armor_heal=6, armor_use=400},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
    reciprocate_damage = true,
    on_damage = function(player) armor:play_sound_effect(player, "default_dig_metal") end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_dug_metal") end,
})