import 'package:flutter_test/flutter_test.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/features/game/domain/combination_resolver.dart';
import 'package:tmatch/core/models/grid.dart';

void main() {
  late CombinationResolver resolver;

  setUp(() {
    resolver = CombinationResolver();
  });

  group('findConnected', () {
    test('returns empty list for empty tile', () {
      final grid = Grid.empty().setCell(
        const Position(0, 0, 0),
        const RegularTile(1),
      );
      final result = resolver.findConnected(grid, const Position(1, 1, 0));
      expect(result, isEmpty);
    });

    test('finds a single tile when no neighbor matches', () {
      final grid = Grid.empty().setCell(
        const Position(0, 0, 0),
        const RegularTile(1),
      );
      final result = resolver.findConnected(grid, const Position(0, 0, 0));
      expect(result, [const Position(0, 0, 0)]);
    });

    test('finds adjacent tiles of the same type', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(0, 1, 0), const RegularTile(1));
      final result = resolver.findConnected(grid, const Position(0, 0, 0));
      expect(result.length, 3);
      expect(
        result,
        containsAll([
          const Position(0, 0, 0),
          const Position(1, 0, 0),
          const Position(0, 1, 0),
        ]),
      );
    });

    test('does not cross different types', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(2));
      final result = resolver.findConnected(grid, const Position(0, 0, 0));
      expect(result.length, 1);
    });

    test('does not include diagonal neighbors', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 1, 0), const RegularTile(1));
      final result = resolver.findConnected(grid, const Position(0, 0, 0));
      expect(result.length, 1);
    });

    test('finds connected tiles through a chain', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(2, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(0, 1, 0), const RegularTile(1));
      final result = resolver.findConnected(grid, const Position(0, 0, 0));
      expect(result.length, 4);
    });
  });

  group('checkCombination', () {
    test('returns null when below threshold (need 3 on floor 0)', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isNull);
    });

    test('returns upgraded type when threshold is met', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(2, 0, 0), const RegularTile(1));
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isA<RegularTile>());
      expect((result as RegularTile).value, 2);
    });

    test('triggers with 4 adjacent tiles on floor 0', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(2, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(3, 0, 0), const RegularTile(1));
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isA<RegularTile>());
      expect((result as RegularTile).value, 2);
    });

    test('triggers with 5 adjacent tiles on floor 0', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(2, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(3, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(4, 0, 0), const RegularTile(1));
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isA<RegularTile>());
      expect((result as RegularTile).value, 2);
    });

    test('upgrades RegularTile 6 to 7', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(6));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(6));
      grid = grid.setCell(const Position(2, 0, 0), const RegularTile(6));
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isA<RegularTile>());
      expect((result as RegularTile).value, 7);
    });

    test('upgrades DiamondTile -5 to -6', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const DiamondTile(-5));
      grid = grid.setCell(const Position(1, 0, 0), const DiamondTile(-5));
      grid = grid.setCell(const Position(2, 0, 0), const DiamondTile(-5));
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isA<DiamondTile>());
      expect((result as DiamondTile).value, -6);
    });

    test('returns null for EnemyTile', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const EnemyTile());
      grid = grid.setCell(const Position(1, 0, 0), const EnemyTile());
      grid = grid.setCell(const Position(2, 0, 0), const EnemyTile());
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isNull);
    });

    test('returns null when upgrade exceeds max type 7', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(7));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(7));
      grid = grid.setCell(const Position(2, 0, 0), const RegularTile(7));
      final connected = resolver.findConnected(grid, const Position(0, 0, 0));
      final result = resolver.checkCombination(
        grid,
        connected,
        const Position(0, 0, 0),
      );
      expect(result, isNull);
    });
  });

  group('matchThreshold on higher floors', () {
    test('requires more tiles on higher virtual floors', () {
      // Virtual floor 1 → matchThreshold = 2 + 1 = 3, so need 4 tiles
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 1), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 1), const RegularTile(1));
      grid = grid.setCell(const Position(2, 0, 1), const RegularTile(1));
      // 3 tiles at virtual floor 1 should NOT trigger
      final connected = resolver.findConnected(grid, const Position(0, 0, 1));
      expect(
        resolver.checkCombination(grid, connected, const Position(0, 0, 1)),
        isNull,
      );
    });

    test('needs 4+ tiles on virtual floor 1', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 1), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 1), const RegularTile(1));
      grid = grid.setCell(const Position(2, 0, 1), const RegularTile(1));
      grid = grid.setCell(const Position(3, 0, 1), const RegularTile(1));
      final connected = resolver.findConnected(grid, const Position(0, 0, 1));
      expect(
        resolver.checkCombination(grid, connected, const Position(0, 0, 1)),
        isNotNull,
      );
    });

    test('does not trigger with 4 tiles on virtual floor 2 (need 5)', () {
      // Virtual floor 2 → matchThreshold = 2 + 2 = 4, so need 5 tiles
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 2), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 2), const RegularTile(1));
      grid = grid.setCell(const Position(2, 0, 2), const RegularTile(1));
      grid = grid.setCell(const Position(3, 0, 2), const RegularTile(1));
      final connected = resolver.findConnected(grid, const Position(0, 0, 2));
      expect(
        resolver.checkCombination(grid, connected, const Position(0, 0, 2)),
        isNull,
      );
    });
  });
}
