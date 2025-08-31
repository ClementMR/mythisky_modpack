--- Registered armors.
--
--  @topic armor


local S = core.get_translator(core.get_current_modname())

--- Cactus
--
--  Requires `armor_material_cactus`.
--
--  @section cactus


--- Cactus Helmet
--
--  @helmet 3d_armor:helmet_cactus
--  @img 3d_armor_inv_helmet_cactus.png
--  @grp armor_head 1
--  @grp armor_heal 0
--  @grp armor_use 1000
--  @armorgrp fleshy 5
--  @damagegrp cracky 3
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:helmet_cactus", {
    description = S("Cactus Helmet"),
    inventory_image = "3d_armor_inv_helmet_cactus.png",
    groups = {armor_head=1, armor_heal=0, armor_use=1000},
    armor_groups = {fleshy=5},
    damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
})
--- Cactus Chestplate
--
--  @chestplate 3d_armor:chestplate_cactus
--  @img 3d_armor_inv_chestplate_cactus.png
--  @grp armor_torso 1
--  @grp armor_heal 0
--  @grp armor_use 1000
--  @armorgrp fleshy 10
--  @damagegrp cracky 3
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:chestplate_cactus", {
    description = S("Cactus Chestplate"),
    inventory_image = "3d_armor_inv_chestplate_cactus.png",
    groups = {armor_torso=1, armor_heal=0, armor_use=1000},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
})
--- Cactus Leggings
--
--  @leggings 3d_armor:leggings_cactus
--  @img 3d_armor_inv_leggings_cactus.png
--  @grp armor_legs 1
--  @grp armor_heal 0
--  @grp armor_use 1000
--  @armorgrp fleshy 10
--  @damagegrp cracky 3
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:leggings_cactus", {
    description = S("Cactus Leggings"),
    inventory_image = "3d_armor_inv_leggings_cactus.png",
    groups = {armor_legs=1, armor_heal=0, armor_use=1000},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
})
--- Cactus Boots
--
--  @boots 3d_armor:boots_cactus
--  @img 3d_armor_inv_boots_cactus.png
--  @grp armor_feet 1
--  @grp armor_heal 0
--  @grp armor_use 1000
--  @armorgrp fleshy 5
--  @damagegrp cracky 3
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor("3d_armor:boots_cactus", {
    description = S("Cactus Boots"),
    inventory_image = "3d_armor_inv_boots_cactus.png",
    groups = {armor_feet=1, armor_heal=0, armor_use=1000},
    armor_groups = {fleshy=5},
    damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
})
--- Cactus Shield
--
--  @shield shields:shield_cactus
--  @img shields_inv_shield_cactus.png
--  @grp armor_shield 1
--  @grp armor_heal 0
--  @grp armor_use 1000
--  @armorgrp fleshy 5
--  @damagegrp cracky 3
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 2
--  @damagegrp level 1
armor:register_armor(":shields:shield_cactus", {
    description = S("Cactus Shield"),
    inventory_image = "shields_inv_shield_cactus.png",
    groups = {armor_shield=1, armor_heal=0, armor_use=1000},
    armor_groups = {fleshy=5},
    damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
    reciprocate_damage = true,
    on_damage = function(player)
        armor:play_sound_effect(player, "default_wood_footstep")
    end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_wood_footstep") end
})
--- Enhanced Cactus Shield
--
--  @shield shields:shield_enhanced_cactus
--  @img shields_inv_shield_enhanced_cactus.png
--  @grp armor_shield 1
--  @grp armor_heal 0
--  @grp armor_use 1000
--  @armorgrp fleshy 8
--  @damagegrp cracky 3
--  @damagegrp snappy 3
--  @damagegrp choppy 2
--  @damagegrp crumbly 2
--  @damagegrp level 2
armor:register_armor(":shields:shield_enhanced_cactus", {
    description = S("Enhanced Cactus Shield"),
    inventory_image = "shields_inv_shield_enhanced_cactus.png",
    groups = {armor_shield=1, armor_heal=0, armor_use=1000},
    armor_groups = {fleshy=8},
    damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=2},
    reciprocate_damage = true,
    on_damage = function(player)
        armor:play_sound_effect(player, "default_dig_metal")
    end,
    on_destroy = function(player) armor:play_sound_effect(player, "default_dug_metal") end
})

core.register_craft({
    output = "shields:shield_enhanced_cactus",
    recipe = {
        {"default:steel_ingot"},
        {"shields:shield_cactus"},
        {"default:steel_ingot"},
    },
})

core.register_craft({
    type = "fuel",
    recipe = "shields:shield_cactus",
    burntime = 16,
})

local cactus_armor_fuel = {
    helmet = 14,
    chestplate = 16,
    leggings = 15,
    boots = 13
}

for armor, burn in pairs(cactus_armor_fuel) do
    core.register_craft({
        type = "fuel",
        recipe = "3d_armor:" .. armor .. "_cactus",
        burntime = burn,
    })
end