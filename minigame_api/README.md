# Minigame API

Core lifecycle:

- `minigame.register(name, def)` registers a game definition and callbacks.
- `minigame.join_game(player, game_name, map_name)` adds a player to a map.
- `minigame.leave_game(player)` removes a player from their current map.
- `minigame.load_map(game_name, map_name, timer)` starts the loading countdown.
- `minigame.start_game(game_name, map_name)` starts a running match.
- `minigame.end_game(game_name, map_name, reason, winners)` ends a match and resets players.

Game options:

- `timed = false` disables automatic end by timer for persistent games.
- `inventory_mode = "clear"` keeps the current arena behavior: clear player inventory on entry and exit.
- `inventory_mode = "keep"` makes the API leave player inventory untouched.
- `inventory_mode = "persistent"` restores a per-game saved inventory on entry and saves it on exit.
- `save_lobby_inventory = true` snapshots the player's current inventory before entering and restores it on exit.
- `include_armor = true` includes 3d_armor inventory in snapshots and clears when relevant.
- `inventory_lists = {"main", "craft"}` controls which player inventory lists are managed.

Persistent game example:

```lua
minigame.register("skyblock", {
    min_players = 1,
    end_match = false,
    timed = false,
    map_regen = false,
    inventory_mode = "persistent",
    save_lobby_inventory = true,
    include_armor = true,
})
```

State helpers:

- `minigame.get_game(game_name)` returns a registered game or `nil`.
- `minigame.get_map(game_name, map_name)` returns a map definition or `nil`.
- `minigame.get_map_state(game_name, map_name)` returns `waiting`, `loading`, `running`, `disabled`, `unknown_game`, or `unknown_map`.
- `minigame.get_map_information(game, map)` returns resolved settings and runtime state.
- `minigame.get_player_entry(player)` returns `{game = ..., map = ...}` or `nil`.
- `minigame.is_player_in_game(player)` returns whether the player is indexed in a game.
- `minigame.get_player_names(map, include_spectators)` returns names for players, optionally including spectators.
- `minigame.save_player_inventory(player, game_name)` saves the current inventory under the game namespace.
- `minigame.restore_player_inventory(player, game_name)` restores the saved game inventory.

Game definition callbacks:

- `on_join(player, map_name)`
- `on_load(map_name, timer)`
- `on_unload(map_name)`
- `on_start(map_name)`
- `on_tick(map_name, timer)`
- `on_end(map_name, reason, winners)`
- `on_die(player_name, map_name)`
- `on_leave(player_name, map_name)`
