--- Registered armors.
--
--  @topic armor


local S = core.get_translator(core.get_current_modname())

--- Diamond
--
--  Requires `armor_material_diamond`.
--
--  @section diamond


--- Diamond Helmet
--
--  @helmet 3d_armor:helmet_diamond
--  @img 3d_armor_inv_helmet_diamond.png
--  @grp armor_head 1
--  @grp armor_heal 12
--  @grp armor_use 200
--  @armorgrp fleshy 15
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp choppy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:helmet_diamond", {
    description = S("Diamond Helmet"),
    inventory_image = "3d_armor_inv_helmet_diamond.png",
    groups = {armor_head=1, armor_heal=12, armor_use=200},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
})
--- Diamond Chestplate
--
--  @chestplate 3d_armor:chestplate_diamond
--  @img 3d_armor_inv_chestplate_diamond.png
--  @grp armor_torso 1
--  @grp armor_heal 12
--  @grp armor_use 200
--  @armorgrp fleshy 20
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp choppy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:chestplate_diamond", {
    description = S("Diamond Chestplate"),
    inventory_image = "3d_armor_inv_chestplate_diamond.png",
    groups = {armor_torso=1, armor_heal=12, armor_use=200},
    armor_groups = {fleshy=20},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
})
--- Diamond Leggings
--
--  @leggings 3d_armor:leggings_diamond
--  @img 3d_armor_inv_leggings_diamond.png
--  @grp armor_legs 1
--  @grp armor_heal 12
--  @grp armor_use 200
--  @armorgrp fleshy 20
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp choppy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:leggings_diamond", {
    description = S("Diamond Leggings"),
    inventory_image = "3d_armor_inv_leggings_diamond.png",
    groups = {armor_legs=1, armor_heal=12, armor_use=200},
    armor_groups = {fleshy=20},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
})
--- Diamond Boots
--
--  @boots 3d_armor:boots_diamond
--  @img 3d_armor_inv_boots_diamond.png
--  @grp armor_feet 1
--  @grp armor_heal 12
--  @grp armor_use 200
--  @armorgrp fleshy 15
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp choppy 1
--  @damagegrp level 3
armor:register_armor("3d_armor:boots_diamond", {
    description = S("Diamond Boots"),
    inventory_image = "3d_armor_inv_boots_diamond.png",
    groups = {armor_feet=1, armor_heal=12, armor_use=200},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
})
--- Diamond Shield
--
--  @shield shields:shield_diamond
--  @img shields_inv_shield_diamond.png
--  @grp armor_shield 1
--  @grp armor_heal 12
--  @grp armor_use 200
--  @armorgrp fleshy 15
--  @damagegrp cracky 2
--  @damagegrp snappy 1
--  @damagegrp choppy 1
--  @damagegrp level 3
armor:register_armor(":shields:shield_diamond", {
    description = S("Diamond Shield"),
    inventory_image = "shields_inv_shield_diamond.png",
    groups = {armor_shield=1, armor_heal=12, armor_use=200},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
    reciprocate_damage = true,
    on_damage = function(player)
        armor:play_sound_effect(player, "default_glass_footstep")
    end,
    on_destroy = function(player)
        armor:play_sound_effect(player, "default_break_glass")
    end,
})