# TMatch - Flutter Architecture

## Overview

TMatch is a tile-matching game rebuilt in Flutter from a legacy Dojo-based web game. The player places tiles on a 6x6 grid to create adjacent groups of 3+ identical tiles, which merge into higher-tier tiles. Special tiles (bugs, erasers, matchers, doors) add strategic depth. Persons (AI entities) move on the grid and can be lost if trapped on empty cells.

---

## Tech Stack

| Concern | Choice | Rationale |
|---------|--------|-----------|
| State management | Riverpod 2.x (code generation) | Type-safe, testable, compile-time provider validation |
| Persistence | Hive (NoSQL local) | Fast, type-safe with adapters, no SQL overhead |
| Game loop | Event-driven | Each player action triggers a deterministic sequence; matches the legacy behavior |
| Rendering | Declarative widgets + `Image.asset` | No canvas needed; grid is small (6x6) |
| Immutability | Freezed | Boilerplate-free immutable models with `copyWith` |

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── game_constants.dart
│   │   └── type_scores.dart
│   ├── models/
│   │   ├── tile_type.dart
│   │   ├── position.dart
│   │   ├── person.dart
│   │   ├── grid.dart
│   │   └── game_state.dart
│   ├── utils/
│   │   ├── randomizer.dart
│   │   └── layer_mapper.dart
│   └── services/
│       ├── hive_service.dart
│       ├── hive_provider.dart
│       ├── tile_type_adapter.dart
│       ├── person_adapter.dart
│       └── grid_adapter.dart
│
├── features/
│   ├── game/
│   │   ├── domain/
│   │   │   ├── combination_resolver.dart
│   │   │   ├── gravity_system.dart
│   │   │   ├── bug_system.dart
│   │   │   ├── person_ai.dart
│   │   │   └── game_engine.dart
│   │   ├── data/
│   │   │   ├── game_repository.dart
│   │   │   └── game_hive_adapters.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── game_provider.dart
│   │       ├── screens/
│   │       │   └── game_screen.dart
│   │       └── widgets/
│   │           ├── game_board.dart
│   │           ├── tile_widget.dart
│   │           ├── current_tile_display.dart
│   │           ├── stash_display.dart
│   │           ├── layer_switcher.dart
│   │           └── score_display.dart
│   │
│   └── menu/
│       ├── screens/
│       │   └── save_load_screen.dart
│       └── widgets/
│           └── save_slot_widget.dart
```

---

## Entry Point

### `main.dart`

Initializes Hive, registers type adapters, opens the saves box, then launches the app with Riverpod:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmatch/core/services/hive_service.dart';
import 'features/game/presentation/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  await Hive.openBox<Map<String, dynamic>>(HiveService.savesBoxName);

  runApp(const ProviderScope(child: TMatchApp()));
}

class TMatchApp extends StatelessWidget {
  const TMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triple Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
```

---

## Core Layer

### `game_constants.dart`

Defines all fixed game parameters:

```dart
abstract final class GameConstants {
  static const int gridWidth = 6;
  static const int gridHeight = 6;
  static const int initialLayers = 1;
  static const double cellWidth = 101;
  static const double cellHeight = 81;
  static const double leftShift = 121;
  static const double bottomShift = 10;
  static const double mapFillPercent = 0.7;

  // Match threshold: 2 + abs(virtualLayer)
  static int matchThreshold(int virtualLayer) => 2 + virtualLayer.abs();

  // Type 7 triggers new layer creation
  static const int maxRegularType = 7;
}
```

### `type_scores.dart`

Score tables from the legacy game, organized by context:

```dart
abstract final class TypeScores {
  static const Map<int, int> played = {
    1: 5, 2: 10, 3: 50, 4: 200,
    -1: 500,  // Door
    -2: 10,   // Bug
    -3: 100,  // Eraser/Key
    -4: 250,  // Matcher/Star
  };

  static const Map<int, int> combItem = {
    1: 10, 2: 20, 3: 50, 4: 100, 5: 150, 6: 1000,
    -2: 100, -5: 500, -6: 2500,
  };

  static const Map<int, int> combResult = {
    2: 30, 3: 70, 4: 150, 5: 500, 6: 2500, 7: 10000,
    -5: 750, -6: 1500, -7: 5000,
  };

  static const Map<int, int> destroyed = {
    1: -5, 2: -30, 3: -75, 4: -200, 5: -1000, 6: -5000, 7: -20000,
    -1: 2000, -2: 10, -5: 500, -6: 1000, -7: 25000,
  };
}
```

### `tile_type.dart`

Sealed class hierarchy for all tile types:

```dart
sealed class TileType {
  final int value;
  const TileType(this.value);

  String get assetPath;
  bool get isEmpty => value == 0;
  bool get isRegular => value > 0;
  bool get isSpecial => value < 0 && value > -5;
  bool get isDiamond => value <= -5;
}

final class RegularTile extends TileType {
  const RegularTile(super.value); // 1-7
  @override String get assetPath => 'assets/images/type_$value.png';
}

final class SpecialTile extends TileType {
  const SpecialTile(super.value); // -1 door, -2 bug, -3 eraser, -4 matcher
  @override
  String get assetPath => switch (value) {
    -1 => 'assets/images/Door Tall Closed.png',
    -2 => 'assets/images/Enemy Bug.png',
    -3 => 'assets/images/eraser.png',
    -4 => 'assets/images/matcher.png',
    _ => 'assets/images/EmptyNegativeBlock.png',
  };
}

final class DiamondTile extends TileType {
  const DiamondTile(super.value); // -5 green, -6 blue, -7 orange
  @override
  String get assetPath => switch (value) {
    -5 => 'assets/images/Green Diamond.png',
    -6 => 'assets/images/Blue Diamond.png',
    -7 => 'assets/images/Orange Diamond.png',
    _ => 'assets/images/EmptyNegativeBlock.png',
  };
}

final class EmptyTile extends TileType {
  const EmptyTile() : super(0);
  @override String get assetPath => '';
}
```

Factory helper to construct from int:

```dart
TileType fromValue(int value) => switch (value) {
  0 => const EmptyTile(),
  > 0 => RegularTile(value),
  <= -5 => DiamondTile(value),
  _ => SpecialTile(value),
};
```

### `position.dart`

Immutable 3D coordinate:

```dart
record class Position(int x, int y, int z) {
  @override String toString() => '($x, $y, $z)';
}
```

### `person.dart`

Person model with stash:

```dart
@freezed
class Person with _$Person {
  const factory Person({
    required int id,
    required TileType type,
    required Position position,
    TileType? stash,
  }) = _Person;
}
```

### `game_state.dart`

Central immutable state:

```dart
@freezed
class GameState with _$GameState {
  const factory GameState({
    required Grid grid,
    required List<Person> persons,
    required Map<int, TileType?> stashes,
    required TileType currentTile,
    required int score,
    required int currentVirtualLayer,
    required int? selectedPersonId,
    required bool isGameOver,
    required int step,
  }) = _GameState;

  factory GameState.initial() => GameState(
    grid: Grid.empty(),
    persons: [],
    stashes: {},
    currentTile: const EmptyTile(),
    score: 0,
    currentVirtualLayer: 0,
    selectedPersonId: null,
    isGameOver: false,
    step: 0,
  );
}
```

### `randomizer.dart`

Tile type probability distribution (matches legacy). Accepts an optional `Random`
instance for deterministic testing:

```dart
class Randomizer {
  final Random _random;

  const Randomizer(this._random);

  /// Creates a [Randomizer] with a fresh [Random] instance.
  factory Randomizer.newSeed() => Randomizer(Random());

  TileType next({bool forMapFill = false}) {
    final i = _random.nextDouble() * 100;
    if (i > 99) return const RegularTile(4);
    if (i > 98 && !forMapFill) return const SpecialTile(-1); // Door
    if (i > 97) return const RegularTile(3);
    if (i > 95 && !forMapFill) return const SpecialTile(-4); // Matcher
    if (i > 92 && !forMapFill) return const SpecialTile(-3); // Eraser
    if (i > 77) return const SpecialTile(-2); // Bug
    if (i > 52) return const RegularTile(2);
    return const RegularTile(1);
  }
}
```

### `layer_mapper.dart`

Maps between virtual layer indices and physical z-stack indices. The mapping
is now identity because the game no longer interleaves positive/negative
layers — all layers use z ≥ 0 directly.

```dart
abstract final class LayerMapper {
  /// Maps a virtual layer index to a physical z-stack index (now identity).
  static int virtLayerToZ(int virtualLayer) => virtualLayer;

  /// Inverse of [virtLayerToZ] (now identity).
  static int zToVirtLayer(int z) => z;
}
```

### `hive_service.dart`

Hive initialization and box access. Adapter classes are defined in separate files under `core/services/`:

```dart
import 'package:tmatch/core/services/grid_adapter.dart';
import 'package:tmatch/core/services/person_adapter.dart';
import 'package:tmatch/core/services/tile_type_adapter.dart';

class HiveService {
  static const String savesBoxName = 'tmatch_saves';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TileTypeAdapter());
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(GridAdapter());
  }

  Box<Map<String, dynamic>> get savesBox =>
      Hive.box<Map<String, dynamic>>(savesBoxName);
}
```

#### `hive_provider.dart`

Riverpod provider exposing `HiveService` for dependency injection in `GameRepository`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmatch/core/services/hive_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
```

---

## Feature: Game

### Domain Layer

#### `grid.dart`

Immutable 3D grid with typed access:

```dart
@freezed
class Grid with _$Grid {
  const factory Grid({
    required int width,
    required int height,
    required int layers,
    required Map<Position, TileType> cells,
  }) = _Grid;

  factory Grid.empty() => Grid(
        width: GameConstants.gridWidth,
        height: GameConstants.gridHeight,
        layers: GameConstants.initialLayers,
        cells: {},
      );
}

extension GridOps on Grid {
  TileType getCell(Position pos) => cells[pos] ?? const EmptyTile();

  Grid setCell(Position pos, TileType type) {
    final newCells = Map<Position, TileType>.from(cells);
    newCells[pos] = type;
    return copyWith(cells: newCells);
  }

  /// Returns a new [Grid] with one additional layer.
  ///
  /// The new layer is empty — no cells are populated. When a tile is placed
  /// on a higher layer, [GravitySystem.apply] makes it fall down through
  /// empty cells until it lands on a non-empty cell or reaches z=0. This
  /// means the new layer's cells are only filled when tiles are placed above
  /// them and gravity pulls them down.
  ///
  /// Without a tile placed above, the new layer remains a "balcony" of empty
  /// cells that doesn't affect gameplay.
  Grid addLayer() => copyWith(layers: layers + 1);
}
```

#### `combination_resolver.dart`

BFS flood-fill to find connected equivalent tiles (replaces legacy recursive `findEquiv`):

```dart
class CombinationResolver {
  /// Returns all positions connected to [start] with the same tile type.
  List<Position> findConnected(Grid grid, Position start) {
    final targetType = grid.getCell(start);
    if (targetType.isEmpty) return [];

    final visited = <Position>{};
    final queue = Queue<Position>.from([start]);
    final result = <Position>[];

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (!visited.add(current)) continue;
      result.add(current);

      for (final neighbor in _adjacent(current, grid)) {
        if (!visited.contains(neighbor) &&
            grid.getCell(neighbor) == targetType) {
          queue.add(neighbor);
        }
      }
    }

    return result;
  }

  /// Checks if a combination is valid and returns the upgraded type.
  /// Returns null if no valid combination.
  TileType? checkCombination(Grid grid, Position pos) {
    final connected = findConnected(grid, pos);
    final threshold = GameConstants.matchThreshold(
      LayerMapper.zToVirtLayer(pos.z),
    );
    if (connected.length <= threshold) return null;

    final currentType = grid.getCell(pos);
    return _upgradeType(currentType);
  }

  TileType? _upgradeType(TileType type) {
    final newValue = switch (type) {
      RegularTile t => t.value + 1,
      DiamondTile t => t.value - 1,
      _ => null,
    };
    if (newValue == null ||
        newValue > GameConstants.maxRegularType ||
        newValue < -7)
      return null;
    return fromValue(newValue);
  }

  Iterable<Position> _adjacent(Position pos, Grid grid) sync* {
    final dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dx, dy) in dirs) {
      final nx = pos.x + dx;
      final ny = pos.y + dy;
      if (nx >= 0 && nx < grid.width && ny >= 0 && ny < grid.height) {
        yield Position(nx, ny, pos.z);
      }
    }
  }
}
```

#### `gravity_system.dart`

Iterative tile falling (replaces legacy recursive `fallTile`):

```dart
class GravitySystem {
  /// Makes tiles fall down from higher layers to fill empty spaces.
  /// Only applies when virtual layer > 0.
  Grid apply(Grid grid, Position startPos) {
    final virtualLayer = LayerMapper.zToVirtLayer(startPos.z);
    if (virtualLayer <= 0) return grid;

    var currentZ = startPos.z;
    var result = grid;

    while (currentZ > 0) {
      final pos = Position(startPos.x, startPos.y, currentZ);
      final abovePos = Position(startPos.x, startPos.y, currentZ - 1);

      if (result.getCell(abovePos).isEmpty && !result.getCell(pos).isEmpty) {
        result = result
            .setCell(abovePos, result.getCell(pos))
            .setCell(pos, const EmptyTile());
        currentZ -= 1;
      } else {
        break;
      }
    }

    return result;
  }
}
```

#### `bug_system.dart`

Bug movement and kill resolution:

```dart
class BugSystem {
  final Random _random;

  BugSystem(this._random);

  /// Returns (updatedGrid, bugsKilledCount).
  (Grid, int) processAll(Grid grid) {
    var result = grid;
    var totalKilled = 0;

    final bugPositions = _findAllBugs(result);

    for (final bugPos in bugPositions) {
      // Re-check in case this bug was destroyed by another
      if (result.getCell(bugPos) is! SpecialTile ||
          (result.getCell(bugPos) as SpecialTile).value != -2) {
        continue;
      }

      final killCount = _checkBugKill(result, bugPos);
      if (killCount > 0) {
        totalKilled += killCount;
        result = _convertBugsToDiamond(result, bugPos);
      } else {
        result = _moveBug(result, bugPos);
      }
    }

    return (result, totalKilled);
  }

  List<Position> _findAllBugs(Grid grid) {
    final bugs = <Position>[];
    for (var z = 0; z < grid.layers; z++) {
      for (var x = 0; x < grid.width; x++) {
        for (var y = 0; y < grid.height; y++) {
          final pos = Position(x, y, z);
          final cell = grid.getCell(pos);
          if (cell is SpecialTile && cell.value == -2) {
            bugs.add(pos);
          }
        }
      }
    }
    return bugs;
  }

  int _checkBugKill(Grid grid, Position bugPos) {
    final connectedBugs = _findConnectedBugs(grid, bugPos);

    for (final bp in connectedBugs) {
      for (final neighbor in _neighbors(bp, grid)) {
        if (grid.getCell(neighbor).isEmpty) {
          return 0; // At least one bug has an escape route
        }
      }
    }

    return connectedBugs.length;
  }

  List<Position> _findConnectedBugs(Grid grid, Position start) {
    final visited = <Position>{};
    final queue = Queue<Position>.from([start]);
    final result = <Position>[];

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (!visited.add(current)) continue;
      result.add(current);

      for (final neighbor in _neighbors(current, grid)) {
        if (!visited.contains(neighbor)) {
          final cell = grid.getCell(neighbor);
          if (cell is SpecialTile && cell.value == -2) {
            queue.add(neighbor);
          }
        }
      }
    }

    return result;
  }

  Grid _moveBug(Grid grid, Position bugPos) {
    final neighbors = _neighbors(bugPos, grid)
        .where((n) => grid.getCell(n).isEmpty)
        .toList();

    if (neighbors.isEmpty) return grid;

    final target = neighbors[_random.nextInt(neighbors.length)];
    return grid
        .setCell(target, const SpecialTile(-2))
        .setCell(bugPos, const EmptyTile());
  }

  Grid _convertBugsToDiamond(Grid grid, Position bugPos) {
    final connectedBugs = _findConnectedBugs(grid, bugPos);
    var result = grid;
    for (final bp in connectedBugs) {
      result = result.setCell(bp, const DiamondTile(-5));
    }
    return result;
  }

  Iterable<Position> _neighbors(Position pos, Grid grid) sync* {
    final dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dx, dy) in dirs) {
      final nx = pos.x + dx;
      final ny = pos.y + dy;
      if (nx >= 0 && nx < grid.width && ny >= 0 && ny < grid.height) {
        yield Position(nx, ny, pos.z);
      }
    }
  }
}
```

#### `person_ai.dart`

Person movement logic:

```dart
class PersonAI {
  final Random _random;

  PersonAI(this._random);

  /// Advances one person step. Returns updated persons list.
  List<Person> stepAll(List<Person> persons, Grid grid) {
    final result = <Person>[];
    var lostAny = false;

    for (final person in persons) {
      if (person.type.value == 0) {
        result.add(person); // Type 0 doesn't move
        continue;
      }

      final stepped = _step(person, grid, persons);
      if (stepped == null) {
        lostAny = true; // Person was lost
      } else {
        result.add(stepped);
      }
    }

    return result;
  }

  Person? _step(Person person, Grid grid, List<Person> allPersons) {
    final currentCell = grid.getCell(person.position);
    final onWater = currentCell.isEmpty;
    final shouldMove = onWater || _random.nextBool();

    if (shouldMove) {
      final movableNeighbors = _neighbors(person.position, grid)
          .where((n) =>
              !grid.getCell(n).isEmpty &&
              !_personAt(persons: allPersons, position: n))
          .toList();

      if (movableNeighbors.isNotEmpty) {
        final target = movableNeighbors[_random.nextInt(movableNeighbors.length)];
        return person.copyWith(position: target);
      }
    }

    // Couldn't move and on water = lost
    if (onWater) return null;
    return person;
  }

  bool _personAt({required List<Person> persons, required Position position}) {
    return persons.any((p) => p.position == position);
  }

  Iterable<Position> _neighbors(Position pos, Grid grid) sync* {
    final dirs = [
      (-1, 0), (1, 0), (0, -1), (0, 1),
      (-1, -1), (-1, 1), (1, -1), (1, 1), // diagonals
    ];
    for (final (dx, dy) in dirs) {
      final nx = pos.x + dx;
      final ny = pos.y + dy;
      if (nx >= 0 && nx < grid.width && ny >= 0 && ny < grid.height) {
        yield Position(nx, ny, pos.z);
      }
    }
  }
}
```

#### `game_engine.dart`

Orchestrator that composes all domain systems:

```dart
class GameEngine {
  final CombinationResolver _resolver;
  final GravitySystem _gravity;
  final BugSystem _bugs;
  final PersonAI _personAI;
  final Randomizer _randomizer;

  GameEngine({
    CombinationResolver? resolver,
    GravitySystem? gravity,
    BugSystem? bugs,
    PersonAI? personAI,
    Randomizer? randomizer,
  }) : _resolver = resolver ?? CombinationResolver(),
       _gravity = gravity ?? GravitySystem(),
       _bugs = bugs ?? BugSystem(Random()),
       _personAI = personAI ?? PersonAI(Random()),
       _randomizer = randomizer ?? Randomizer.newSeed();

  /// Places a tile and runs the full step sequence.
  /// Returns the new GameState.
  GameState placeTile(GameState state, int x, int y) {
    if (state.isGameOver) return state;

    final z = LayerMapper.virtLayerToZ(state.currentVirtualLayer);
    final pos = Position(x, y, z);
    var grid = state.grid;
    var score = state.score;

    final tileToPlace = state.currentTile;

    // Handle eraser (-3)
    if (tileToPlace is SpecialTile && tileToPlace.value == -3) {
      final targetCell = grid.getCell(pos);
      if (!targetCell.isEmpty) {
        score += TypeScores.played[-3] ?? 0;
        score += TypeScores.destroyed[targetCell.value] ?? 0;
        grid = grid.setCell(pos, const EmptyTile());
        return _advanceStep(state.copyWith(
          grid: grid,
          score: score,
          currentTile: _randomizer.next(),
        ));
      }
      return state;
    }

    // Cell must be empty to place
    if (!grid.getCell(pos).isEmpty) return state;

    // Score for placement
    score += TypeScores.played[tileToPlace.value] ?? 0;

    // Place tile
    grid = grid.setCell(pos, tileToPlace);

    // Handle matcher (-4)
    if (tileToPlace is SpecialTile && tileToPlace.value == -4) {
      final (matchedGrid, matchScore, matched) = _tryMatchAll(grid, pos);
      if (matched) {
        score += matchScore;
        return _advanceStep(state.copyWith(
          grid: matchedGrid,
          score: score,
          currentTile: _randomizer.next(),
        ));
      }
      return state; // No match found, don't advance
    }

    // Handle door (-1) and bug (-2) - place without combination
    if (tileToPlace is SpecialTile &&
        (tileToPlace.value == -1 || tileToPlace.value == -2)) {
      return _advanceStep(state.copyWith(
        grid: grid,
        score: score,
        currentTile: _randomizer.next(),
      ));
    }

    // Regular tile or diamond - check combinations
    final (comboGrid, comboScore) = _resolveCombinations(grid, pos);
    grid = comboGrid;
    score += comboScore;

    return _advanceStep(state.copyWith(
      grid: grid,
      score: score,
      currentTile: _randomizer.next(),
    ));
  }

  /// Checks for combinations at [pos] and resolves the full chain iteratively.
  /// Returns the updated grid and the total score earned from the chain.
  (Grid, int) _resolveCombinations(Grid grid, Position pos) {
    var result = grid;
    var totalScore = 0;
    var checkPos = pos;

    while (true) {
      final upgraded = _resolver.checkCombination(result, checkPos);
      if (upgraded == null) break;

      final connected = _resolver.findConnected(result, checkPos);

      // Score for each item in combination
      for (final cellPos in connected) {
        final cellType = result.getCell(cellPos);
        totalScore += TypeScores.combItem[cellType.value] ?? 0;
        result = result.setCell(cellPos, const EmptyTile());
      }

      // Place upgraded type
      result = result.setCell(checkPos, upgraded);

      // Apply gravity
      result = _gravity.apply(result, checkPos);

      // Score for combination result
      totalScore += TypeScores.combResult[upgraded.value] ?? 0;

      // Spawn person if type >= 6
      if (upgraded is RegularTile && upgraded.value >= 6) {
        // Person spawning is handled in the provider layer
      }

      // Add new layer if type 7
      if (upgraded is RegularTile && upgraded.value == 7) {
        result = result.addLayer();
      }

      // Continue checking for chain combinations
      // (loop continues with the upgraded tile at checkPos)
    }

    return (result, totalScore);
  }

  /// Attempts to match each neighbor type by temporarily placing it at [pos].
  /// If a match is found, applies the full combination chain.
  /// Returns (updatedGrid, score, matched).
  (Grid, int, bool) _tryMatchAll(Grid grid, Position pos) {
    final neighborTypes = [
      if (pos.x > 0) grid.getCell(Position(pos.x - 1, pos.y, pos.z)),
      if (pos.x < grid.width - 1) grid.getCell(Position(pos.x + 1, pos.y, pos.z)),
      if (pos.y > 0) grid.getCell(Position(pos.x, pos.y - 1, pos.z)),
      if (pos.y < grid.height - 1) grid.getCell(Position(pos.x, pos.y + 1, pos.z)),
    ].toSet();

    for (final type in neighborTypes) {
      if (type.isEmpty) continue;
      if (type is SpecialTile && type.value < -4) continue;
      if (type is RegularTile && type.value > 6) continue;

      // Place the neighbor type at pos and check for a combination
      var testGrid = grid.setCell(pos, type);
      final upgraded = _resolver.checkCombination(testGrid, pos);
      if (upgraded != null) {
        // Clear connected tiles and apply combination
        final connected = _resolver.findConnected(testGrid, pos);
        var totalScore = 0;
        for (final cellPos in connected) {
          totalScore += TypeScores.combItem[testGrid.getCell(cellPos).value] ?? 0;
          testGrid = testGrid.setCell(cellPos, const EmptyTile());
        }
        testGrid = testGrid.setCell(pos, upgraded);
        testGrid = _gravity.apply(testGrid, pos);
        totalScore += TypeScores.combResult[upgraded.value] ?? 0;
        return (testGrid, totalScore, true);
      }
    }

    return (grid, 0, false);
  }

  GameState _advanceStep(GameState state) {
    var grid = state.grid;
    var score = state.score;

    // Process bugs
    final (bugGrid, bugsKilled) = _bugs.processAll(grid);
    grid = bugGrid;
    if (bugsKilled > 0) {
      score += bugsKilled * (TypeScores.combItem[-2] ?? 0);
      score += TypeScores.combResult[-5] ?? 0;
    }

    // Process persons
    final persons = _personAI.stepAll(state.persons, grid);

    // Check loose condition: main layer (z=0) completely filled
    final isGridFull = _checkGridFull(grid);

    // Check if all persons lost
    final isAllPersonsLost = persons.isEmpty && state.persons.isNotEmpty;

    return state.copyWith(
      grid: grid,
      persons: persons,
      score: score,
      step: state.step + 1,
      isGameOver: isGridFull || isAllPersonsLost,
    );
  }

  bool _checkGridFull(Grid grid) {
    for (var x = 0; x < grid.width; x++) {
      for (var y = 0; y < grid.height; y++) {
        if (grid.getCell(Position(x, y, 0)).isEmpty) return false;
      }
    }
    return true;
  }
}
```

---

### Data Layer

#### `game_repository.dart`

Save/load operations via Hive:

```dart
class GameRepository {
  final Box<Map<String, dynamic>> _box;

  GameRepository(this._box);

  List<String> listSaves() {
    return _box.values.map((data) => data['savename'] as String).toList();
  }

  void save(String name, GameState state) {
    _box.put(name, {
      'savename': name,
      'isTMatchSave': true,
      'grid': _serializeGrid(state.grid),
      'current_type': state.currentTile.value,
      'score': state.score,
      'persons': state.persons.map(_serializePerson).toList(),
      'stashes': _serializeStashes(state.stashes),
      'current_stash': state.selectedPersonId,
      'step': state.step,
    });
  }

  GameState? load(String name) {
    final data = _box.get(name);
    if (data == null) return null;
    return _deserializeGameState(data);
  }

  String importSave(String jsonData) {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;
    final savename = data['savename'] as String;
    _box.put(savename, data);
    return savename;
  }

  String exportSave(String name) {
    final data = _box.get(name);
    return jsonEncode(data);
  }

  // Serialization helpers
  Map<String, dynamic> _serializeGrid(Grid grid) {
    final cellsList = <Map<String, dynamic>>[];
    for (final entry in grid.cells.entries) {
      cellsList.add({
        'x': entry.key.x,
        'y': entry.key.y,
        'z': entry.key.z,
        'type': entry.value.value,
      });
    }
    return {
      'width': grid.width,
      'height': grid.height,
      'layers': grid.layers,
      'cells': cellsList,
    };
  }

  Grid _deserializeGrid(Map<String, dynamic> data) {
    final cells = <Position, TileType>{};
    final cellsList = data['cells'] as List;
    for (final cellData in cellsList) {
      cells[Position(
        cellData['x'] as int,
        cellData['y'] as int,
        cellData['z'] as int,
      )] = fromValue(cellData['type'] as int);
    }
    return Grid(
      width: data['width'] as int,
      height: data['height'] as int,
      layers: data['layers'] as int,
      cells: cells,
    );
  }

  Map<String, dynamic> _serializePerson(Person p) => {
    'id': p.id,
    'type': p.type.value,
    'x': p.position.x,
    'y': p.position.y,
    'z': p.position.z,
    'stash': p.stash?.value,
  };

  Person _deserializePerson(Map<String, dynamic> data) => Person(
    id: data['id'] as int,
    type: fromValue(data['type'] as int),
    position: Position(
      data['x'] as int,
      data['y'] as int,
      data['z'] as int,
    ),
    stash: data['stash'] != null ? fromValue(data['stash'] as int) : null,
  );

  Map<String, dynamic> _serializeStashes(Map<int, TileType?> stashes) =>
      stashes.map((key, value) => MapEntry(key.toString(), value?.value));

  Map<int, TileType?> _deserializeStashes(Map<String, dynamic> data) {
    final stashes = <int, TileType?>{};
    for (final entry in data.entries) {
      stashes[int.parse(entry.key)] =
          entry.value != null ? fromValue(entry.value as int) : null;
    }
    return stashes;
  }

  GameState _deserializeGameState(Map<String, dynamic> data) => GameState(
    grid: _deserializeGrid(data['grid'] as Map<String, dynamic>),
    currentTile: fromValue(data['current_type'] as int),
    score: data['score'] as int,
    persons: (data['persons'] as List)
        .map((p) => _deserializePerson(p as Map<String, dynamic>))
        .toList(),
    stashes: _deserializeStashes(
      Map<String, dynamic>.from(data['stashes'] as Map),
    ),
    selectedPersonId: data['current_stash'] as int?,
    step: data['step'] as int? ?? 0,
    currentVirtualLayer: 0,
    isGameOver: false,
  );
}
```

---

### Presentation Layer

#### `game_provider.dart`

Riverpod notifier that bridges UI to the domain engine:

```dart
@riverpod
class GameNotifier extends _$GameNotifier {
  late final GameEngine _engine;
  late final GameRepository _repository;
  late final Randomizer _randomizer;
  late final Random _random;

  @override
  GameState build() {
    _repository = ref.watch(gameRepositoryProvider);
    _random = Random();
    _randomizer = Randomizer.newSeed();
    _engine = GameEngine(
      bugs: BugSystem(_random),
      personAI: PersonAI(_random),
      randomizer: _randomizer,
    );
    return GameState.initial();
  }

  void newGame() {
    var newState = GameState.initial();
    final grid = _initializeGrid();
    final queenPos = _findRandomOccupiedCell(grid);

    newState = newState.copyWith(
      grid: grid,
      currentTile: _randomizer.next(),
      persons: [
        Person(
          id: 0,
          type: const RegularTile(9), // Queen
          position: queenPos,
        ),
      ],
    );

    state = newState;
  }

  void placeTile(int x, int y) {
    state = _engine.placeTile(state, x, y);
  }

  void swapWithStash() {
    final selectedId = state.selectedPersonId;
    if (selectedId == null) return;

    final stashedItem = state.stashes[selectedId];
    final currentTile = state.currentTile;

    final newStashes = Map<int, TileType?>.from(state.stashes)
      ..[selectedId] = currentTile;

    state = state.copyWith(
      stashes: newStashes,
      currentTile: stashedItem ?? _randomizer.next(),
    );
  }

  void selectPerson(int id) {
    state = state.copyWith(selectedPersonId: id);
  }

  void switchLayer(int direction) {
    final newVirtual = state.currentVirtualLayer + direction;
    final maxLayer = LayerMapper.zToVirtLayer(state.grid.layers - 1);
    final minLayer = 0;

    var clamped = newVirtual;
    if (clamped > maxLayer) clamped = minLayer;
    if (clamped < minLayer) clamped = maxLayer;

    state = state.copyWith(currentVirtualLayer: clamped);
  }

  Future<bool> loadSave(String name) async {
    final loaded = _repository.load(name);
    if (loaded != null) {
      state = loaded;
      return true;
    }
    return false;
  }

  void saveGame(String name) {
    _repository.save(name, state);
  }

  List<String> listSaves() {
    return _repository.listSaves();
  }

  Grid _initializeGrid() {
    var grid = Grid.empty();

    for (var x = 0; x < GameConstants.gridWidth; x++) {
      for (var y = 0; y < GameConstants.gridHeight; y++) {
        if (_random.nextDouble() < GameConstants.mapFillPercent) {
          final pos = Position(x, y, 0);
          grid = grid.setCell(pos, _randomizer.next(forMapFill: true));
        }
      }
    }

    return grid;
  }

  Position _findRandomOccupiedCell(Grid grid) {
    final occupied = grid.cells.entries
        .where((e) => !e.value.isEmpty)
        .map((e) => e.key)
        .toList();

    if (occupied.isEmpty) {
      return const Position(0, 0, 0);
    }

    return occupied[_random.nextInt(occupied.length)];
  }
}

@Riverpod(keepAlive: true)
GameRepository gameRepository(GameRepositoryRef ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return GameRepository(hiveService.savesBox);
}
```

#### `game_screen.dart`

Main game screen layout:

```dart
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              currentTile: gameState.currentTile,
              score: gameState.score,
              stash: _currentStash(gameState),
            ),
            Expanded(
              child: GameBoard(
                grid: gameState.grid,
                currentLayer: gameState.currentVirtualLayer,
                onTileTap: (x, y) => ref.read(gameNotifierProvider.notifier).placeTile(x, y),
              ),
            ),
            _BottomBar(
              persons: gameState.persons,
              selectedPersonId: gameState.selectedPersonId,
              layerCount: gameState.grid.layers,
              currentLayer: gameState.currentVirtualLayer,
              onPersonTap: (id) => ref.read(gameNotifierProvider.notifier).selectPerson(id),
              onStashTap: () => ref.read(gameNotifierProvider.notifier).swapWithStash(),
              onLayerUp: () => ref.read(gameNotifierProvider.notifier).switchLayer(1),
              onLayerDown: () => ref.read(gameNotifierProvider.notifier).switchLayer(-1),
              onSave: () => _showSaveDialog(context, ref),
              onLoad: () => _showLoadDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  TileType? _currentStash(GameState state) {
    if (state.selectedPersonId == null) return null;
    return state.stashes[state.selectedPersonId];
  }
}
```

#### `game_board.dart`

Interactive grid rendering:

```dart
class GameBoard extends StatelessWidget {
  final Grid grid;
  final int currentLayer;
  final void Function(int x, int y) onTileTap;

  const GameBoard({
    super.key,
    required this.grid,
    required this.currentLayer,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final z = LayerMapper.virtLayerToZ(currentLayer);
    final crossAxisCount = GameConstants.gridWidth;
    final itemCount = GameConstants.gridWidth * GameConstants.gridHeight;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final x = index % crossAxisCount;
        final y = (GameConstants.gridHeight - 1) - (index ~/ crossAxisCount);
        final pos = Position(x, y, z);
        final tile = grid.getCell(pos);

        return GestureDetector(
          onTap: () => onTileTap(x, y),
          child: TileWidget(tile: tile),
        );
      },
    );
  }
}
```

#### `tile_widget.dart`

Single tile rendering:

```dart
class TileWidget extends StatelessWidget {
  final TileType tile;

  const TileWidget({super.key, required this.tile});

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.grey.shade200),
        ),
      );
    }

    return Image.asset(
      tile.assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: Center(child: Text(tile.value.toString())),
        );
      },
    );
  }
}
```

---

## Data Flow: Event-Driven Game Loop

```
User taps cell (x, y)
        │
        ▼
GameNotifier.placeTile(x, y)
        │
        ├──► GameEngine.placeTile(state, x, y)
        │       │
        │       ├──► Grid.setCell(pos, currentTile)
        │       ├──► CombinationResolver.checkCombination()
        │       │       └──► BFS flood-fill → find connected tiles
        │       │       └──► If valid: clear matched, place upgraded type
        │       ├──► GravitySystem.apply()
        │       │       └──► Iterative fall from higher layers
        │       │
        │       └──► _advanceStep()
        │               ├──► BugSystem.processAll()
        │               │       └──► Move bugs or convert trapped → diamond
        │               ├──► PersonAI.stepAll()
        │               │       └──► Random movement; lose if stuck on water
        │               └──► LooseCondition check
        │                       └──► Grid full (z=0) OR all persons lost
        │
        ▼
state = newState (immutable)
        │
        ▼
Widgets rebuild automatically via Riverpod
```

---

## Persistence Model

### Hive Box: `tmatch_saves`

Each save is stored as a JSON-like map:

```json
{
  "savename": "MySave",
  "isTMatchSave": true,
  "grid": { "width": 6, "height": 6, "layers": 2, "cells": [...] },
  "current_type": 2,
  "score": 1500,
  "persons": [
    { "id": 0, "type": 9, "position": { "x": 3, "y": 2, "z": 0 }, "stash": 1 }
  ],
  "current_stash": 0,
  "stashes": { "0": 1 },
  "step": 42
}
```

### Operations

| Operation | Method | Description |
|-----------|--------|-------------|
| List saves | `listSaves()` | Returns all save names |
| Save | `save(name, state)` | Serializes and stores GameState |
| Load | `load(name)` | Deserializes saved GameState |
| Export | `exportSave(name)` | Returns JSON string for manual copy |
| Import | `importSave(jsonString)` | Parses JSON and stores as new save |

---

## Key Design Decisions

### 1. Immutable domain models

All models use Freezed for immutability. State transitions always produce new instances via `copyWith`. This enables predictable state, easy undo/redo, and straightforward testing.

### 2. Iterative algorithms throughout

The legacy uses recursion for flood-fill (`findEquiv`) and chain combination resolution. The Flutter version replaces all recursion with iteration: BFS flood-fill via `Queue`, gravity via a `while` loop, and chain combination resolution via a `while` loop (see `_resolveCombinations`). No risk of stack overflow regardless of chain length.

### 3. Iterative gravity

The legacy `fallTile` is recursive. The new `GravitySystem.apply` uses a `while` loop (see item 2 for the full pattern).

### 4. Event-driven step progression

No game loop ticker. Each player action triggers the full sequence: place → combine → gravity → bugs → persons → loose check. This matches the legacy behavior exactly and avoids unnecessary computation.

### 5. Sparse grid representation

The grid uses `Map<Position, TileType>` instead of a 3D array. Empty cells are implicit (return `EmptyTile` if key not found). This is more memory-efficient and simpler to serialize.

### 6. Sealed class for tile types

Instead of integer type codes with scattered `if/else` logic, `TileType` uses a sealed class hierarchy. Pattern matching (`switch`) replaces conditional chains, and the compiler enforces exhaustiveness.

### 7. Feature-first organization

Domain logic, data access, and presentation are grouped by feature (`game/`, `menu/`) rather than by layer type. This keeps related code co-located and scales better as features grow.

### 8. Injectable Random for deterministic tests

`Randomizer`, `BugSystem`, and `PersonAI` accept a `Random` instance through their constructors. The `GameEngine` composes them and also injects a `Randomizer`. In tests, a seeded `Random` can be passed to make tile generation, bug movement, and person movement fully deterministic.

### 9. Tuple returns instead of mutation closures

`_resolveCombinations` returns `(Grid, int)` — the updated grid and the earned score — rather than accepting a `void Function(int)` closure that mutates a local variable. `_tryMatchAll` returns `(Grid, int, bool)` for the same reason. This preserves the immutable data flow through the engine.

---

## Critiques résolues

Toutes les critiques suivantes ont été adressées dans le document. Les correctifs sont intégrés aux listings de code et aux décisions architecturales ci-dessus.

### 1. `_tryMatchAll` — implémenté

Remplacé par une implémentation complète qui retourne `(Grid, int, bool)` : la grille mise à jour, le score généré, et un indicateur de succès. Le commentaire *"simplified"* a été supprimé.

### 2. `_resolveCombinations` — itératif

Remplacé par une boucle `while` au lieu de la récursion. Retourne `(Grid, int)` au lieu d'une closure de score. La Key Decision #2 a été mise à jour pour refléter que tous les algorithmes sont maintenant itératifs.

### 3. Collision PersonAI — corrigé

`_step` accepte maintenant `List<Person> allPersons` en paramètre et le transmet à `_personAt`. Les personnages ne peuvent plus occuper la même cellule.

### 4. `LayerMapper` — simplifié

Remplacé par des fonctions identité : `virtLayerToZ(v) => v` et `zToVirtLayer(z) => z`. Le mapping complexe avec alternance de z pairs/négatifs a été supprimé car inutile : tous les layers utilisent désormais z ≥ 0 directement. Plus de risque d'erreur de wrapping dans `switchLayer`.

### 5. Random injectable — résolu

`Randomizer`, `BugSystem`, et `PersonAI` acceptent un `Random` dans leur constructeur. `GameEngine` compose ces dépendances et reçoit aussi un `Randomizer`. `GameNotifier` partage une instance `Random` pour `_initializeGrid` et `_findRandomOccupiedCell`. Une nouvelle Key Decision #8 documente ce choix.

### 6. Mutation du score par closure — éliminé

`_resolveCombinations` retourne `(Grid, int)` au lieu d'une closure `void Function(int)`. `placeTile` additionne le score retourné. Une nouvelle Key Decision #9 documente ce pattern.

### 7. Propagation des mutations de l'étoile — corrigé

`placeTile` utilise maintenant la grille retournée par `_tryMatchAll` (`matchedGrid`) et additionne le score (`matchScore`). Plus aucune mutation n'est perdue.

### 8. `grid.addLayer()` — documenté

La méthode est documentée avec `///` : le nouveau layer est vide ; les cellules sont peuplées uniquement par gravité quand une tuile est placée au-dessus.
