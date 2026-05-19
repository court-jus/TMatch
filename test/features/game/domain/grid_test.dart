import 'package:flutter_test/flutter_test.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/models/grid.dart';

void main() {
  group('Grid.empty()', () {
    test('creates a 6x6 grid with 1 floor and no cells', () {
      final grid = Grid.empty();
      expect(grid.width, 6);
      expect(grid.height, 6);
      expect(grid.floors, 1);
      expect(grid.cells, isEmpty);
    });
  });

  group('getCell', () {
    test('returns EmptyTile for unset positions', () {
      final grid = Grid.empty();
      expect(grid.getCell(const Position(0, 0, 0)), isA<EmptyTile>());
      expect(grid.getCell(const Position(5, 5, 0)), isA<EmptyTile>());
    });
  });

  group('setCell', () {
    test('returns a new grid with the cell set', () {
      final grid = Grid.empty();
      final modified = grid.setCell(
        const Position(2, 3, 0),
        const RegularTile(1),
      );
      expect(grid.getCell(const Position(2, 3, 0)), isA<EmptyTile>());
      expect(modified.getCell(const Position(2, 3, 0)), isA<RegularTile>());
      expect(
        (modified.getCell(const Position(2, 3, 0)) as RegularTile).value,
        1,
      );
    });
  });

  group('addFloor', () {
    test('increments floors without modifying cells', () {
      final grid = Grid.empty();
      final modified = grid.addFloor();
      expect(modified.floors, 2);
      expect(modified.cells, isEmpty);
    });
  });
}
