import 'package:flutter_test/flutter_test.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/features/game/domain/gravity_system.dart';
import 'package:tmatch/core/models/grid.dart';

void main() {
  late GravitySystem gravity;

  setUp(() {
    gravity = GravitySystem();
  });

  group('apply', () {
    test('does nothing when virtual floor is 0 (z=0)', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      final result = gravity.apply(grid, const Position(0, 0, 0));
      expect(result.getCell(const Position(0, 0, 0)), isA<RegularTile>());
    });

    test('makes tile fall down through all empty floors below', () {
      // Gravity cascades the tile all the way to z=0 when all cells below are empty
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 3), const RegularTile(1));
      final result = gravity.apply(grid, const Position(0, 0, 3));
      expect(result.getCell(const Position(0, 0, 3)), isA<EmptyTile>());
      expect(result.getCell(const Position(0, 0, 0)), isA<RegularTile>());
    });

    test(
      'cascades tile through multiple empty floors until hitting a tile',
      () {
        // z=5 (virtual floor 2), nothing below at z=4 nor z=3, but tile at z=2
        var grid = Grid.empty();
        grid = grid.setCell(const Position(0, 0, 2), const RegularTile(2));
        grid = grid.setCell(const Position(0, 0, 5), const RegularTile(1));
        final result = gravity.apply(grid, const Position(0, 0, 5));
        expect(result.getCell(const Position(0, 0, 5)), isA<EmptyTile>());
        expect(result.getCell(const Position(0, 0, 4)), isA<EmptyTile>());
        // Falls to z=3 (just above the tile at z=2)
        expect(result.getCell(const Position(0, 0, 3)), isA<RegularTile>());
        expect(result.getCell(const Position(0, 0, 2)), isA<RegularTile>());
        expect(result.getCell(const Position(0, 0, 2)).value, 2);
      },
    );

    test('stops falling when cell above is not empty', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 3), const RegularTile(1));
      grid = grid.setCell(const Position(0, 0, 2), const RegularTile(2));
      final result = gravity.apply(grid, const Position(0, 0, 3));
      // Tile at z=3 stays because z=2 is occupied
      expect(result.getCell(const Position(0, 0, 3)), isA<RegularTile>());
    });

    test('does nothing when no tile is present at start position', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 3), const EmptyTile());
      final result = gravity.apply(grid, const Position(0, 0, 3));
      expect(result, grid);
    });
  });
}
