import 'dart:math';

import 'package:tmatch/core/constants/type_scores.dart';
import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/utils/floor_mapper.dart';
import 'package:tmatch/core/utils/randomizer.dart';
import 'bug_system.dart';
import 'combination_resolver.dart';
import 'gravity_system.dart';
import 'package:tmatch/core/models/grid.dart';
import 'person_ai.dart';

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

    final z = FloorMapper.virtualFloorToZ(state.currentFloor);
    final pos = Position(x, y, z);
    var grid = state.grid;
    var score = state.score;

    final tileToPlace = state.currentTile;

    // Handle eraser (-3)
    if (tileToPlace is KeyTile) {
      final targetCell = grid.getCell(pos);
      if (!targetCell.isEmpty) {
        score += TypeScores.played[-3] ?? 0;
        score += TypeScores.destroyed[targetCell.value] ?? 0;
        grid = grid.setCell(pos, const EmptyTile());
        final nextTile = _randomizer.next();
        print('[NEXT] t=${nextTile.value}');
        return _advanceStep(
          state.copyWith(grid: grid, score: score, currentTile: nextTile),
        );
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
    if (tileToPlace is StarTile) {
      final (matchedGrid, matchScore, matched, matchPersons) = _tryMatchAll(
        grid,
        pos,
        state.persons,
      );
      if (matched) {
        score += matchScore;
        final nextTile = _randomizer.next();
        print('[NEXT] t=${nextTile.value}');
        return _advanceStep(
          state.copyWith(
            grid: matchedGrid,
            score: score,
            currentTile: nextTile,
            persons: [...state.persons, ...matchPersons],
          ),
        );
      }
      return state; // No match found, don't advance
    }

    // Handle door (-1) and bug (-2) - place without combination
    if (tileToPlace is DoorTile || tileToPlace is EnemyTile) {
      final nextTile = _randomizer.next();
      print('[NEXT] t=${nextTile.value}');
      return _advanceStep(
        state.copyWith(grid: grid, score: score, currentTile: nextTile),
      );
    }

    // Regular tile or diamond - check combinations
    print('[PLACE] (${pos.x},${pos.y},${pos.z}) t=${tileToPlace.value}');
    final (comboGrid, comboScore, comboPersons) = _resolveCombinations(
      grid,
      pos,
      state.persons,
    );
    grid = comboGrid;
    score += comboScore;

    final nextTile = _randomizer.next();
    print('[NEXT] t=${nextTile.value}');
    return _advanceStep(
      state.copyWith(
        grid: grid,
        score: score,
        currentTile: nextTile,
        persons: [...state.persons, ...comboPersons],
      ),
    );
  }

  /// Checks for combinations at [pos] and resolves the full chain iteratively.
  /// Returns the updated grid, the total score, and any newly spawned persons.
  (Grid, int, List<Person>) _resolveCombinations(
    Grid grid,
    Position pos,
    List<Person> existingPersons,
  ) {
    var result = grid;
    var totalScore = 0;
    var checkPos = pos;
    var spawnedPersons = <Person>[];

    while (true) {
      final connected = _resolver.findConnected(result, checkPos);
      final upgraded = _resolver.checkCombination(result, connected, checkPos);
      if (upgraded == null) break;

      final oldType = result.getCell(checkPos);

      // Score and clear each item in combination
      for (final cellPos in connected) {
        final cellType = result.getCell(cellPos);
        print(
          '[CLEAR] (${cellPos.x},${cellPos.y},${cellPos.z}) t=${cellType.value}',
        );
        totalScore += TypeScores.combItem[cellType.value] ?? 0;
        result = result.setCell(cellPos, const EmptyTile());
      }

      // Place upgraded type
      result = result.setCell(checkPos, upgraded);
      print(
        '[UPGRADE] (${checkPos.x},${checkPos.y},${checkPos.z}) old=${oldType.value} new=${upgraded.value}',
      );

      // Apply gravity
      result = _gravity.apply(result, checkPos);

      // Score for combination result
      totalScore += TypeScores.combResult[upgraded.value] ?? 0;

      // Spawn person if type >= 6
      if (upgraded is RegularTile && upgraded.value >= 6) {
        final maxId = existingPersons.isEmpty
            ? -1
            : existingPersons.map((p) => p.id).reduce(max);
        final nextId = maxId + 1 + spawnedPersons.length;
        final allCurrentPersons = [...existingPersons, ...spawnedPersons];
        final spawnPos = _findFreePosition(checkPos, allCurrentPersons, result);
        spawnedPersons.add(
          Person(id: nextId, type: PersonTile(10), position: spawnPos),
        );
      }

      // Add new floor if type 7
      if (upgraded is RegularTile && upgraded.value == 7) {
        result = result.addFloor();
      }

      // Continue checking for chain combinations
      // (loop continues with the upgraded tile at checkPos)
    }

    return (result, totalScore, spawnedPersons);
  }

  /// Attempts to match each neighbor type by temporarily placing it at [pos].
  /// If a match is found, applies the full combination chain.
  /// Returns (updatedGrid, score, matched, spawnedPersons).
  (Grid, int, bool, List<Person>) _tryMatchAll(
    Grid grid,
    Position pos,
    List<Person> existingPersons,
  ) {
    final neighborTypes = <TileType>{
      if (pos.x > 0) grid.getCell(Position(pos.x - 1, pos.y, pos.z)),
      if (pos.x < grid.width - 1)
        grid.getCell(Position(pos.x + 1, pos.y, pos.z)),
      if (pos.y > 0) grid.getCell(Position(pos.x, pos.y - 1, pos.z)),
      if (pos.y < grid.height - 1)
        grid.getCell(Position(pos.x, pos.y + 1, pos.z)),
    };

    for (final type in neighborTypes) {
      if (type.isEmpty) continue;
      if (type is DiamondTile) continue;
      if (type is RegularTile && type.value > 6) continue;

      // Place the neighbor type at pos and check for a combination
      var testGrid = grid.setCell(pos, type);
      print('[MATCHER] trying t=${type.value}');
      final connected = _resolver.findConnected(testGrid, pos);
      final upgraded = _resolver.checkCombination(testGrid, connected, pos);
      if (upgraded != null) {
        // Delegate full resolution (clearing, upgrade, gravity, chain reactions,
        // scoring, person spawning) to _resolveCombinations
        final (chainGrid, chainScore, chainPersons) = _resolveCombinations(
          testGrid,
          pos,
          existingPersons,
        );
        return (chainGrid, chainScore, true, chainPersons);
      }
    }

    return (grid, 0, false, []);
  }

  GameState _advanceStep(GameState state) {
    var grid = state.grid;
    var score = state.score;

    // Process bugs
    final (bugGrid, bugsKilled, diamondPositions) = _bugs.processAll(grid);
    grid = bugGrid;
    var newPersons = <Person>[];
    if (bugsKilled > 0) {
      score += bugsKilled * (TypeScores.combItem[-2] ?? 0);
      score += TypeScores.combResult[-5] ?? 0;
      for (final pos in diamondPositions) {
        final (comboGrid, comboScore, comboPersons) = _resolveCombinations(
          grid,
          pos,
          [...state.persons, ...newPersons],
        );
        grid = comboGrid;
        score += comboScore;
        newPersons.addAll(comboPersons);
      }
    }

    // Process existing persons, then append newly spawned ones
    final processedPersons = _personAI.stepAll(state.persons, grid);
    final persons = [...processedPersons, ...newPersons];

    // Check loose condition: main floor (z=0) completely filled
    final isGridFull = _checkGridFull(grid);

    // Check if all persons lost
    final isAllPersonsLost = persons.isEmpty && state.persons.isNotEmpty;

    final gameOverReason = isGridFull
        ? GameOverReason.gridFull
        : isAllPersonsLost
        ? GameOverReason.allPersonsLost
        : null;

    var nextState = state.copyWith(
      grid: grid,
      persons: persons,
      score: score,
      step: state.step + 1,
      isGameOver: gameOverReason != null,
      gameOverReason: gameOverReason,
    );

    // Only check placement viability if game isn't already over
    if (!nextState.isGameOver) {
      nextState = checkPlacementViability(nextState);
    }

    return nextState;
  }

  /// Returns the state with isGameOver set to true if neither the current
  /// tile nor any stashed tile has a valid placement on the grid.
  GameState checkPlacementViability(GameState state) {
    if (state.isGameOver) return state;

    if (_hasValidPlacement(state.currentTile, state.grid)) return state;

    // Current tile can't be placed; check stashes
    if (_canAnyStashBePlaced(state.stashes, state.grid)) return state;

    // Star escape hatch: if the current tile is a Star with no valid placement,
    // check whether the player can escape by stashing.
    if (state.currentTile is StarTile) {
      final allStashesAreStars =
          state.stashes.isNotEmpty &&
          state.stashes.values.every((s) => s is StarTile);
      if (allStashesAreStars) {
        // Every stash is occupied by a Star → cannot escape by swapping.
        // Re-roll a non-Star and recheck viability.
        return checkPlacementViability(
          state.copyWith(currentTile: _randomizer.nextExcluding({-4})),
        );
      }
      // Empty stash slot or a non-Star stash exists → player can stash
      // the current Star to get a new tile. Do not end the game.
      return state;
    }

    return state.copyWith(
      isGameOver: true,
      gameOverReason: GameOverReason.noValidPlacement,
    );
  }

  bool _hasValidPlacement(TileType tile, Grid grid) {
    if (tile.value == -4) {
      return _hasValidStarPlacement(grid);
    }

    for (var x = 0; x < grid.width; x++) {
      for (var y = 0; y < grid.height; y++) {
        for (var z = 0; z < grid.floors; z++) {
          final pos = Position(x, y, z);
          final cell = grid.getCell(pos);
          if (tile.value == -3) {
            // Eraser: needs a non-empty cell to erase
            if (!cell.isEmpty) return true;
          } else {
            // Everything else: needs an empty cell
            if (cell.isEmpty) return true;
          }
        }
      }
    }
    return false;
  }

  /// Returns true if placing a Star anywhere on the grid would form a match.
  bool _hasValidStarPlacement(Grid grid) {
    for (var x = 0; x < grid.width; x++) {
      for (var y = 0; y < grid.height; y++) {
        for (var z = 0; z < grid.floors; z++) {
          final pos = Position(x, y, z);
          if (!grid.getCell(pos).isEmpty) continue;
          if (_wouldStarMatchAt(pos, grid)) return true;
        }
      }
    }
    return false;
  }

  /// Simulates a Star placed at [pos] by trying each neighbor type.
  /// Returns true if any neighbor type would form a valid combination.
  bool _wouldStarMatchAt(Position pos, Grid grid) {
    final neighborTypes = <TileType>{
      if (pos.x > 0) grid.getCell(Position(pos.x - 1, pos.y, pos.z)),
      if (pos.x < grid.width - 1)
        grid.getCell(Position(pos.x + 1, pos.y, pos.z)),
      if (pos.y > 0) grid.getCell(Position(pos.x, pos.y - 1, pos.z)),
      if (pos.y < grid.height - 1)
        grid.getCell(Position(pos.x, pos.y + 1, pos.z)),
    };

    for (final type in neighborTypes) {
      if (type.isEmpty) continue;
      if (type is DiamondTile) continue;
      if (type is RegularTile && type.value > 6) continue;

      var testGrid = grid.setCell(pos, type);
      final connected = _resolver.findConnected(testGrid, pos);
      final upgraded = _resolver.checkCombination(testGrid, connected, pos);
      if (upgraded != null) return true;
    }
    return false;
  }

  bool _canAnyStashBePlaced(Map<int, TileType?> stashes, Grid grid) {
    return stashes.values.any(
      (stash) => stash != null && _hasValidPlacement(stash, grid),
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

  /// Finds the nearest free position to [preferred] not occupied by a person.
  /// Falls back to [preferred] if no free cell is found.
  Position _findFreePosition(
    Position preferred,
    List<Person> allPersons,
    Grid grid,
  ) {
    if (!allPersons.any((p) => p.position == preferred)) {
      return preferred;
    }

    final visited = <Position>{preferred};
    final queue = <Position>[preferred];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      for (final (dx, dy) in _neighborOffsets) {
        final next = Position(current.x + dx, current.y + dy, preferred.z);
        if (next.x < 0 ||
            next.x >= grid.width ||
            next.y < 0 ||
            next.y >= grid.height ||
            visited.contains(next)) {
          continue;
        }
        if (!allPersons.any((p) => p.position == next)) {
          return next;
        }
        visited.add(next);
        queue.add(next);
      }
    }

    return preferred;
  }
}

const _neighborOffsets = [
  (-1, 0),
  (1, 0),
  (0, -1),
  (0, 1),
  (-1, -1),
  (-1, 1),
  (1, -1),
  (1, 1),
];
