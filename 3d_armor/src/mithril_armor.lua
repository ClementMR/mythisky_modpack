--- Registered armors.
--
--  @topic armor


local S = core.get_translator(core.get_current_modname())

--- Mithril
--
--  Requires `armor_material_mithril`.
--
--  @section mithril


--- Mithril Helmet
--
--  @helmet 3d_armor:helmet_mithril
--  @img 3d_armor_inv_helmet_mithril.png
--  @grp armor_head 1
--  @grp armor_heal 12
--  @grp armor_use 100
--  @armorgrp fleshy 15
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:helmet_mithril", {
    description = S("Mithril Helmet"),
    inventory_image = "3d_armor_inv_helmet_mithril.png",
    groups = {armor_head=1, armor_heal=13, armor_use=66},
    armor_groups = {fleshy=16},
    damage_groups = {cracky=2, snappy=1, level=3},
})
--- Mithril Chestplate
--
--  @chestplate 3d_armor:chestplate_mithril
--  @img 3d_armor_inv_chestplate_mithril.png
--  @grp armor_torso 1
--  @grp armor_heal 12
--  @grp armor_use 100
--  @armorgrp fleshy 20
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:chestplate_mithril", {
    description = S("Mithril Chestplate"),
    inventory_image = "3d_armor_inv_chestplate_mithril.png",
    groups = {armor_torso=1, armor_heal=13, armor_use=66},
    armor_groups = {fleshy=21},
    damage_groups = {cracky=2, snappy=1, level=3},
})
--- Mithril Leggings
--
--  @leggings 3d_armor:leggings_mithril
--  @img 3d_armor_inv_leggings_mithril.png
--  @grp armor_legs 1
--  @grp armor_heal 12
--  @grp armor_use 100
--  @armorgrp fleshy 20
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:leggings_mithril", {
    description = S("Mithril Leggings"),
    inventory_image = "3d_armor_inv_leggings_mithril.png",
    groups = {armor_legs=1, armor_heal=13, armor_use=66},
    armor_groups = {fleshy=21},
    damage_groups = {cracky=2, snappy=1, level=3},
})
--- Mithril Boots
--
--  @boots 3d_armor:boots_mithril
--  @img 3d_armor_inv_boots_mithril.png
--  @grp armor_feet 1
--  @grp armor_heal 12
--  @grp armor_use 100
--  @armorgrp fleshy 15
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:boots_mithril", {
    description = S("Mithril Boots"),
    inventory_image = "3d_armor_inv_boots_mithril.png",
    groups = {armor_feet=1, armor_heal=13, armor_use=66},
    armor_groups = {fleshy=16},
    damage_groups = {cracky=2, snappy=1, level=3},
})
--- Mithril Shield
--
--  @shield shields:shield_mithril
--  @img shields_inv_shield_mithril.png
--  @grp armor_shield 1
--  @grp armor_heal 12
--  @grp armor_use 100
--  @armorgrp fleshy 15
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp level 3
armor:register_armor(":shields:shield_mithril", {
    description = S("Mithril Shield"),
    inventory_image = "shields_inv_shield_mithril.png",
    groups = {armor_shield=1, armor_heal=13, armor_use=66},
    armor_groups = {fleshy=16},
    damage_groups = {cracky=2, snappy=1, level=3},
    reciprocate_damage = true,
    on_damage = function(player) armor:play_sound_effect(player, "default_glass_footstep") end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_break_glass") end,
})