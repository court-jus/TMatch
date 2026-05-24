# Stars

Stars match whatever adjacent tile type they have and upgrades.

## Placement check

Stars have stricter placement requirements than other tiles. A Star is **placeable** only if placing it in an empty cell would actually form a **3+ combination**. The old code used `_hasAdjacentMatchable` which only checked for any matchable neighbor — this was too permissive because a single adjacent tile of the right type cannot form a combination alone.

The check now simulates the actual Star placement using `_hasValidStarPlacement` + `_wouldStarMatchAt`: for every empty cell, each cardinal neighbor type is temporarily placed and checked with `findConnected` + `checkCombination`. Only if a real upgrade would occur is the cell considered valid.

## Star deadlock

When the randomizer picks a Star that has **no valid placement** (simulation finds no cell where a match would form):

- **All stashes contain Stars** (and at least one stash exists): the Star is automatically re-rolled to a non-Star tile via `_randomizer.nextExcluding({-4})`. The new tile is rechecked for viability recursively.

- **Some stash is empty** (or holds a non-Star tile): the game does **not** end. The player can stash the Star manually into the empty/non-Star slot and get a new random tile.

- **All stashes full of unplaceable Stars** is the only case where the auto re-roll fires — the player has no escape via swapping.

The escape hatch lives in `GameEngine.checkPlacementViability` in `game_engine.dart`. It fires only after the standard checks (current tile placeable → stash tile placeable → Star deadlock) have all failed.
