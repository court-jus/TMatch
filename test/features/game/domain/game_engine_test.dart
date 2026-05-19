import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/utils/randomizer.dart';
import 'package:tmatch/features/game/domain/bug_system.dart';
import 'package:tmatch/features/game/domain/combination_resolver.dart';
import 'package:tmatch/features/game/domain/game_engine.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/features/game/domain/gravity_system.dart';
import 'package:tmatch/features/game/domain/person_ai.dart';

/// A [Randomizer] that always returns a predetermined tile type.
/// Used to make tile selection deterministic in tests.
class FakeRandomizer extends Randomizer {
  final TileType forcedTile;

  FakeRandomizer(this.forcedTile) : super(Random(0));

  @override
  TileType next({bool forMapFill = false}) => forcedTile;
}

void main() {
  late GameEngine engine;
  late Random seededRandom;
  late FakeRandomizer fakeRandomizer;
  late GameState initialState;

  setUp(() {
    seededRandom = Random(42);
    fakeRandomizer = FakeRandomizer(const RegularTile(1));
    engine = GameEngine(
      resolver: CombinationResolver(),
      gravity: GravitySystem(),
      bugs: BugSystem(seededRandom),
      personAI: PersonAI(seededRandom),
      randomizer: fakeRandomizer,
    );
    initialState = GameState.initial().copyWith(
      currentTile: const RegularTile(1),
    );
  });

  group('placeTile', () {
    test('returns unchanged state when game is already over', () {
      final overState = initialState.copyWith(isGameOver: true);
      final result = engine.placeTile(overState, 0, 0);
      expect(result, overState);
    });

    test('returns unchanged state when target cell is occupied', () {
      var grid = initialState.grid;
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      final occupiedState = initialState.copyWith(grid: grid);
      final result = engine.placeTile(occupiedState, 0, 0);
      expect(result, occupiedState);
    });

    test('places a regular tile and increments step', () {
      final result = engine.placeTile(initialState, 0, 0);
      expect(result.step, 1);
      expect(result.score, 5); // TypeScores.played[1] = 5
      expect(result.grid.getCell(const Position(0, 0, 0)), isA<RegularTile>());
    });

    test('does not trigger combination with only 2 tiles', () {
      var state = initialState;
      state = engine.placeTile(state, 0, 0);
      state = state.copyWith(currentTile: const RegularTile(1));
      state = engine.placeTile(state, 1, 0);
      // score = 5 + 5 = 10 from placement; no combination score
      expect(state.score, 10);
    });

    test('triggers combination with 3 adjacent tiles of the same type', () {
      var state = initialState;
      state = engine.placeTile(state, 0, 0); // score 5
      state = state.copyWith(currentTile: const RegularTile(1));
      state = engine.placeTile(state, 1, 0); // score 10
      state = state.copyWith(currentTile: const RegularTile(1));
      state = engine.placeTile(state, 2, 0); // triggers combo
      // Scores: 5 + 5 + 5 (placement) + 10*3 (combo items) + 30 (combo result)
      expect(state.score, 5 + 5 + 5 + 10 * 3 + 30);
      // The three type-1 tiles should be gone, replaced by one type-2 at (2,0,0)
      final cell = state.grid.getCell(const Position(2, 0, 0));
      expect(cell, isA<RegularTile>());
      expect((cell as RegularTile).value, 2);
    });

    test('eraser removes the target tile and adds score', () {
      var grid = initialState.grid;
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(2));
      final state = initialState.copyWith(
        grid: grid,
        currentTile: const KeyTile(),
      );
      final result = engine.placeTile(state, 0, 0);
      // Erased: 100 (played) + (-30) (destroyed type 2) = 70
      expect(result.score, 70);
      expect(result.grid.getCell(const Position(0, 0, 0)), isA<EmptyTile>());
    });

    test('matcher matches with an adjacent tile type', () {
      var grid = initialState.grid;
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      final state = initialState.copyWith(
        grid: grid,
        currentTile: const StarTile(),
      );
      final result = engine.placeTile(state, 2, 0);
      // Matcher at (2,0) should match with two type-1 tiles → 3 match, upgrade to type 2
      expect(result.score, greaterThan(0));
      expect(result.step, greaterThan(0));
    });

    test('matcher chains combination when upgraded tile forms another match', () {
      // Set up: type 1 tiles at (0,0),(1,0); type 2 tiles at (0,1),(1,1),(2,1)
      // Matcher at (2,0) → matches type 1 → upgrade to type 2 at (2,0)
      // Type 2 at (2,0) is adjacent to type 2 at (2,1) → chains with (0,1),(1,1)
      var grid = initialState.grid;
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(0, 1, 0), const RegularTile(2));
      grid = grid.setCell(const Position(1, 1, 0), const RegularTile(2));
      grid = grid.setCell(const Position(2, 1, 0), const RegularTile(2));
      final state = initialState.copyWith(
        grid: grid,
        currentTile: const StarTile(),
      );
      final result = engine.placeTile(state, 2, 0);
      // First match: 3 type-1 cleared → type-2 at (2,0)
      // Chain: 4 type-2 cleared (2,0 + 0,1 + 1,1 + 2,1) → type-3 at (2,0)
      expect(result.step, 1);
      final cell = result.grid.getCell(const Position(1, 0, 0));
      expect(cell, isA<EmptyTile>());
      final upgraded = result.grid.getCell(const Position(2, 0, 0));
      expect(upgraded, isA<RegularTile>());
      expect((upgraded as RegularTile).value, 3);
    });

    test(
      'matcher does nothing and does not advance when no neighbor matches',
      () {
        var grid = initialState.grid;
        grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
        final state = initialState.copyWith(
          grid: grid,
          currentTile: const StarTile(),
        );
        final result = engine.placeTile(state, 5, 5);
        // Star placed at (5,5) with no neighbors → no match → no advancement
        expect(result, state);
      },
    );

    test('door is placed without combination', () {
      var grid = initialState.grid;
      grid = grid.setCell(const Position(0, 0, 0), const DoorTile());
      grid = grid.setCell(const Position(1, 0, 0), const DoorTile());
      final state = initialState.copyWith(
        grid: grid,
        currentTile: const DoorTile(),
      );
      final result = engine.placeTile(state, 2, 0);
      expect(result.step, 1);
      expect(result.grid.getCell(const Position(2, 0, 0)), isA<DoorTile>());
    });

    test('bug is placed without combination and advances', () {
      final state = initialState.copyWith(currentTile: const EnemyTile());
      final result = engine.placeTile(state, 0, 0);
      expect(result.step, 1);
      // Bug may move via bug processing; verify it exists somewhere on floor 0
      var bugFound = false;
      for (var x = 0; x < 6 && !bugFound; x++) {
        for (var y = 0; y < 6 && !bugFound; y++) {
          final cell = result.grid.getCell(Position(x, y, 0));
          if (cell is EnemyTile) bugFound = true;
        }
      }
      expect(bugFound, isTrue);
    });
  });

  group('chain combination', () {
    test('chains multiple combinations in one turn', () {
      // Place type-2 tiles that combine to type-3, which also triggers
      var state = initialState;
      // Set up type-2 tiles first
      var grid = initialState.grid;
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(2));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(2));
      state = initialState.copyWith(
        grid: grid,
        currentTile: const RegularTile(2),
      );
      // Placing a third type-2 at (2,0,0) should trigger type-2 → type-3
      state = engine.placeTile(state, 2, 0);
      // Upgraded tile at (2,0,0) should be type 3
      final cell = state.grid.getCell(const Position(2, 0, 0));
      expect(cell, isA<RegularTile>());
      expect((cell as RegularTile).value, 3);
    });
  });

  group('game over', () {
    test('triggers game over when grid is completely filled', () {
      // Fill all 36 cells of z=0 with alternating types so no combination forms
      var grid = initialState.grid;
      for (var x = 0; x < 6; x++) {
        for (var y = 0; y < 6; y++) {
          grid = grid.setCell(Position(x, y, 0), RegularTile((x + y) % 2 + 1));
        }
      }
      // Remove one cell to allow the last placement
      grid = grid.setCell(const Position(0, 0, 0), const EmptyTile());
      var state = initialState.copyWith(
        grid: grid,
        currentTile: const RegularTile(1),
      );
      state = engine.placeTile(state, 0, 0);
      expect(state.isGameOver, isTrue);
      expect(state.gameOverReason, GameOverReason.gridFull);
    });

    test('checkPlacementViability sets gameOverReason to noValidPlacement', () {
      // Fill every cell on every floor
      var grid = initialState.grid;
      for (var z = 0; z < grid.floors; z++) {
        for (var x = 0; x < grid.width; x++) {
          for (var y = 0; y < grid.height; y++) {
            grid = grid.setCell(Position(x, y, z), const RegularTile(1));
          }
        }
      }
      final state = initialState.copyWith(
        grid: grid,
        currentTile: const RegularTile(2),
      );
      final result = engine.checkPlacementViability(state);
      expect(result.isGameOver, isTrue);
      expect(result.gameOverReason, GameOverReason.noValidPlacement);
    });
  });
}
