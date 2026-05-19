# Legacy Code - TMatch

## Overview

TMatch is a browser-based tile-matching game built with **Dojo Toolkit** (circa 2008-2012 era). The game uses a 6x6 grid where players place tiles to create matches of 3+ identical adjacent tiles, which then merge into higher-tier tiles.

## Architecture

### Files
| File | Purpose |
|------|---------|
| `tmatch.js` | Core game logic (837 lines) |
| `utils.js` | Utility functions (sort_unique, language detection) |
| `saveload.js` | Save/load system using localStorage |
| `doc.js` | Documentation/help display toggle |

### Tech Stack
- **Framework**: Dojo Toolkit (`dojo`, `dijit.Dialog`)
- **Storage**: `localStorage` for save games
- **Rendering**: DOM-based with CSS classes for tile types
- **Language**: Auto-detects browser language (fr/en)

---

## Game Mechanics

### Grid
- **Dimensions**: 6x6 (`WIDTH = 6`, `HEIGHT = 6`)
- **Layers**: Starts at 1, can expand dynamically (sky/underground layers)
- **Cell size**: 101x81 pixels with offset positioning

### Tile Types

#### Regular Tiles (positive integers)
| Type | Class | Description |
|------|-------|-------------|
| 1 | `type_1` | Basic tile (most common, ~45%) |
| 2 | `type_2` | Second tier (~25%) |
| 3 | `type_3` | Third tier (~3%) |
| 4 | `type_4` | Fourth tier (~1%) |

#### Special Tiles (negative integers)
| Type | Class | Name | Description |
|------|-------|------|-------------|
| -1 | `door` | Door | Rare special tile (~1%) |
| -2 | `bug` | Bug | Moves randomly, can be killed (~5%) |
| -3 | `eraser` | Key/Eraser | Removes any tile it touches (~3%) |
| -4 | `matcher` | Star | Auto-matches all possible combinations at target cell (~2%) |
| -5 | `gdiamond` | Green Diamond | Result of bug kill combination |
| -6 | `bdiamond` | Blue Diamond | Higher tier diamond |
| -7 | `odiamond` | Orange Diamond | Highest tier diamond |

#### Persons
| Type | Class | Description |
|------|-------|-------------|
| 1 | `person1` | Regular person (spawned from type 6+ matches) |
| 9 | `queen` | Queen (placed once at game start) |

### Tile Generation (`randomType`)
Probability distribution per tile spawn:
- Type 1: 0-52% (52%)
- Type 2: 52-77% (25%)
- Bug (-2): 77-92% (15%)
- Key/Eraser (-3): 92-95% (3%)
- Star/Matcher (-4): 95-98% (3%)
- Type 3: 98-99% (1%)
- Type 4: 99-100% (1%)
- Door (-1): 98-99% (1%, only on non-random map fills)

---

## Core Gameplay Loop

### 1. Tile Placement
Player clicks a cell on the grid to place the `current_type` tile:

- **Empty cell + regular tile**: Places tile, checks for combinations
- **Eraser (-3)**: Destroys the target tile (scores based on destroyed tile value)
- **Matcher (-4)**: Attempts to auto-match all adjacent tile types at that cell
- **Door (-1) / Bug (-2)**: Places directly without combination check

### 2. Combination Logic (`checkComb`)
When tiles are placed, `findEquiv` performs flood-fill to find all connected identical tiles:

**Match threshold**: `comb.length > 2 + Math.abs(zToVirtLayer(z))`
- Layer 0: need 3+ tiles
- Layer 1+: need 4+ tiles (harder to match on higher layers)

**On successful match**:
1. All matched tiles are cleared
2. A new tile of type `t+1` is created at the placement position
3. Tiles above fall down (`fallTile`)
4. Recursive check for chain combinations
5. Score awarded for both `comb_item` and `comb_result`

**Tier escalation**:
- Regular: 1→2→3→4→5→6→7 (type 7 triggers new layer creation)
- Diamonds: -5→-6→-7

### 3. Step Progression (`doOneStep`)
After each placement:
1. New random tile type is selected for `current_type`
2. **Bugs move**: Each bug attempts to move to a random adjacent empty cell. If trapped (no empty neighbors), bugs are killed and converted to green diamonds (-5)
3. **Persons move**: Each person (except type 0) randomly moves to adjacent cells with tiles. If on water (empty cell) and cannot move, they are lost
4. **Loose condition**: If main layer (z=0) is completely filled with no empty cells → game over

---

## Layer System

### Virtual Layer Mapping
Layers use a virtual coordinate system mapped to physical z indices:

| Virtual Layer | Physical z | Display Zone |
|---------------|------------|--------------|
| 0 | 0 | Main |
| 1 | 1 | Sky |
| -1 | 2 | Underground |
| 2 | 3 | Sky |
| -2 | 4 | Underground |

### Layer Creation
- Triggered when a match produces type 7
- `addNewLayer()` creates a new empty layer and increments `LAYERS`
- Layer switcher UI appears when LAYERS > 1 (up) or > 2 (down)

### Gravity
- `fallTile`: Tiles fall from higher layers to fill empty spaces below
- Only applies when virtual layer > 0

---

## Person System

### Persons
- Spawn when matches produce type 6+ tiles
- Have their own DOM nodes in `personscontainer`
- Move independently on the grid with AI behavior

### Person Behavior (`doPersonStep`)
1. 50% chance to move (100% if standing on water/empty cell)
2. Chooses random adjacent cell that has a tile and no other person
3. If on water and cannot move → `loosePerson()` (removed from game)
4. If last person is lost → game over ("Looser")

### Queen
- Type 9 person placed at game start on a random tile
- Does not move (type !== 0 check in `doPersonStep`)

### Stash System
- Each person has a stash (inventory slot)
- Clicking stash swaps `current_type` with stashed item
- Person tooltip shows stashed item type

---

## Scoring System

### Score Tables (`TYPE_SCORE`)

#### `played` (tile placement)
| Type | Score |
|------|-------|
| 4 | 200 |
| 3 | 50 |
| 2 | 10 |
| 1 | 5 |
| -1 (Door) | 500 |
| -2 (Bug) | 10 |
| -3 (Key) | 100 |
| -4 (Star) | 250 |

#### `comb_item` (per tile in combination)
| Type | Score |
|------|-------|
| 1-6 | 10-1000 |
| -2 (Bug) | 100 |
| -5 (GDiamond) | 500 |
| -6 (BDiamond) | 2500 |

#### `comb_result` (result of combination)
| New Type | Score |
|----------|-------|
| 2-7 | 30-10000 |
| -5 (GDiamond) | 750 |
| -6 (BDiamond) | 1500 |
| -7 (ODiamond) | 5000 |

#### `destroyed` (when eraser destroys a tile)
| Type | Score |
|------|-------|
| 1-7 | -5 to -20000 (negative = penalty for destroying high tiers!) |
| -1 (Door) | 2000 |
| -2 (Bug) | 10 |
| -5 (GDiamond) | 500 |
| -6 (BDiamond) | 1000 |
| -7 (ODiamond) | 25000 |

**Note**: Destroying high-tier regular tiles gives negative scores (penalty), while destroying special tiles gives positive scores.

---

## Save/Load System (`saveload.js`)

### Storage
- Uses `localStorage` with key prefix `TMatch_savegame_`
- Saves: map state, current_type, score, persons (position/type), stashes

### Features
- **Save**: Named saves via dialog input
- **Load**: Lists all saves, click to load
- **Export**: Converts save to JSON string for manual copy
- **Import**: Paste JSON string to import a save

---

## UI Components (dynamically created)

| Element | ID | Purpose |
|---------|----|---------|
| Current tile display | `current` | Shows next tile to place |
| Score display | `score` | Current score |
| Stash display | `stash` | Current person's stash (clickable to swap) |
| Play zones | `playzone`, `playzone_sky`, `playzone_underground` | Grid containers per layer type |
| Persons container | `personscontainer` | Holds person DOM nodes |
| Layer display | `currentLayerDisplay` | Shows current virtual layer number |
| Layer switcher | `upswitch`, `dnswitch` | Navigate between layers |
| Save/Load buttons | `savebtn`, `loadbtn` | Open save/load dialogs |

---

## Game Initialization (`initGame`)

### New Game
1. Clears all state (map, persons, stashes, score)
2. Creates UI elements
3. Generates random map (~70% fill rate)
4. Places queen on a random tile
5. Sets initial `current_type`

### Loaded Game
1. Loads saved state from localStorage
2. Reconstructs map and persons
3. Restores stashes and score

---

## Loose Conditions

Game ends when:
1. **Grid full**: No empty cells on main layer (z=0)
2. **Last person lost**: All persons have been removed from the game

Displays "Looser" message (note: typo in original code).

---

## Notable Quirks

1. **Typo**: "Looser" instead of "Loser" throughout the codebase
2. **Typo**: "neighboor" instead of "neighbor"
3. **Dojo dependency**: Heavy reliance on Dojo Toolkit (deprecated in modern web dev)
4. **Global state**: All game state in global variables (map, score, personsmap, etc.)
5. **No module system**: All functions in global scope
6. **Recursive flood-fill**: `findEquiv` uses recursion which could stack overflow on large connected regions
7. **Water mechanic**: Empty cells are treated as "water" that persons can drown in
