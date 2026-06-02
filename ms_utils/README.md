# MS Utils

Shared helpers for Skylith mods.

Base helpers:

- `ms_utils.bool_or(value, default)`
- `ms_utils.number_or(value, default)`
- `ms_utils.copy_sequence(value, default)`
- `ms_utils.contains(list, expected)`
- `ms_utils.is_vector(value)`

Player inventory helpers:

- `ms_utils.player.serialize_inventory(player, options)`
- `ms_utils.player.restore_inventory(player, data, options)`
- `ms_utils.player.clear_inventory(player, options)`
- `ms_utils.player.set_inventory_items(player, items, options)`
- `ms_utils.player.save_inventory(player, key, options)`
- `ms_utils.player.get_saved_inventory(player, key)`
- `ms_utils.player.restore_saved_inventory(player, key, options)`
- `ms_utils.player.delete_saved_inventory(player, key)`
- `ms_utils.player.get_spawnpoint()`
- `ms_utils.player.teleport_to_spawn(player)`
- `ms_utils.player.reset_health(player)`
- `ms_utils.player.set_minimap(player, enabled)`

Supported inventory options:

```lua
{
    lists = {"main", "craft"},
    include_armor = true,
}
```

When `include_armor` is true and `3d_armor` is available, armor inventory is saved, restored, and cleared with the player inventory.

Chat helpers:

- `ms_utils.chat.send_to_names(names, message)`
- `ms_utils.chat.send_to_players(players, message)`
- `ms_utils.chat.send_to_connected(message, predicate)`
