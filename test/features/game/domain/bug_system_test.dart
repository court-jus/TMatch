import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/features/game/domain/bug_system.dart';
import 'package:tmatch/core/models/grid.dart';

void main() {
  late BugSystem bugSystem;
  late Random seededRandom;

  setUp(() {
    seededRandom = Random(42);
    bugSystem = BugSystem(seededRandom);
  });

  group('processAll', () {
    test('moves a bug when it has an empty neighbor', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const EnemyTile());
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      final (result, killed, _) = bugSystem.processAll(grid);
      // Bug should have moved to one of the empty cells
      final bugCount = _countBugs(result);
      expect(bugCount, 1);
      expect(killed, 0);
      // Bug should no longer be at original position
      expect(result.getCell(const Position(0, 0, 0)), isNot(isA<EnemyTile>()));
    });

    test('kills a bug when completely surrounded by non-empty cells', () {
      var grid = Grid.empty();
      // Surround position (1,1,0) with blocks
      grid = grid.setCell(const Position(0, 1, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 1, 0), const EnemyTile());
      grid = grid.setCell(const Position(2, 1, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 2, 0), const RegularTile(1));
      final (result, killed, _) = bugSystem.processAll(grid);
      expect(killed, 1);
      // Bug should be converted to green diamond (-5)
      final cell = result.getCell(const Position(1, 1, 0));
      expect(cell, isA<DiamondTile>());
      expect((cell as DiamondTile).value, -5);
    });

    test('kills connected bugs when all are trapped together', () {
      var grid = Grid.empty();
      // Two adjacent bugs with no escape
      grid = grid.setCell(const Position(0, 0, 0), const EnemyTile());
      grid = grid.setCell(const Position(1, 0, 0), const EnemyTile());
      // Surround them
      grid = grid.setCell(const Position(2, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(0, 1, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 1, 0), const RegularTile(1));
      final (result, killed, _) = bugSystem.processAll(grid);
      expect(killed, 2);
      expect(result.getCell(const Position(0, 0, 0)), isA<DiamondTile>());
      expect(result.getCell(const Position(1, 0, 0)), isA<DiamondTile>());
    });

    test('does not kill bug when at least one escape route exists', () {
      var grid = Grid.empty();
      // Surround on 3 sides but leave (1,2,0) open
      grid = grid.setCell(const Position(0, 1, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 1, 0), const EnemyTile());
      grid = grid.setCell(const Position(2, 1, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      // (1,2,0) is empty → escape route
      final (result, killed, _) = bugSystem.processAll(grid);
      expect(killed, 0);
      // Bug should have moved or stayed
      expect(_countBugs(result), 1);
    });
  });

  group('processAll across floors', () {
    test('processes bugs on all floors', () {
      var grid = Grid.empty();
      // Bugs on two different floors (z=0 and z=1, though z=1 isn't a valid physical z typically)
      grid = grid.setCell(const Position(0, 0, 0), const EnemyTile());
      grid = grid.setCell(const Position(0, 0, 1), const EnemyTile());
      final (result, killed, _) = bugSystem.processAll(grid);
      expect(_countBugs(result), 2);
      expect(killed, 0);
    });
  });
}

int _countBugs(Grid grid) {
  var count = 0;
  for (final cell in grid.cells.values) {
    if (cell is EnemyTile) {
      count++;
    }
  }
  return count;
}
