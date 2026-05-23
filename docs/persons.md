# Little persons

## Init

When the game starts, a random tile is filled with a tier 1 block (`RegularTile(1)`). The queen (`PersonTile(9)`) is positioned on this starting cell.

## Spawning

When a combination resolves to a tile of value >= 6, a new person spawns at that position. If the tile is already occupied by another person, the spawner searches outward (BFS, 8-directional) for the nearest free cell on the same floor.

## Movement

Each time the player places a tile, all persons attempt to move to a random walkable neighbor tile (8-directional). If no walkable neighbor is available and the tile under the person disappeared, the person drowns.

**Two persons can never occupy the same tile:**
- During **movement**, each person's move is checked against already-moved persons (with their new positions) and unprocessed persons (with their old positions), so two persons cannot both move to the same target in a single turn.
- During **spawning**, the system searches for the nearest free position if the spawn tile is occupied.

**Persons cannot move onto:**
- Empty tiles (water)
- Diamond tiles
- Bugs
- Closed doors

## Drowning

If the tile a person stands on is cleared by a combination and none of the neighbor tiles are walkable, the person is removed from play.

## Stash

Each little person can hold one stash (a tile kept for later use).

When a little person holds a tile, they show a little bubble telling which tile they're holding (for example: "Dirt Bubble.png").

When the player wants to stash a tile, they have to click on the "stash" button.

If there's a tile in the stash already, it's swapped with the current one.

If more than one person are present in the grid, the player can click on each of them to scroll through all the available stashes.

## Logging

Person activity is logged with the `[PERSON]` tag:

- `[PERSON] p=0 (3,4,0) -> (2,4,0)` — person 0 moved from (3,4,0) to (2,4,0)
- `[PERSON] p=1 (0,0,0) drown` — person 1 drowned
