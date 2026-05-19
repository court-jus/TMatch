import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/features/game/domain/person_ai.dart';

void main() {
  late PersonAI personAI;
  late Random seededRandom;

  setUp(() {
    seededRandom = Random(42);
    personAI = PersonAI(seededRandom);
  });

  group('stepAll', () {
    test('returns an empty list when no persons exist', () {
      final grid = Grid.empty();
      final result = personAI.stepAll([], grid);
      expect(result, isEmpty);
    });

    test('moves a person (including queen) to a non-empty neighbor', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      final queen = Person(
        id: 0,
        type: const RegularTile(9),
        position: const Position(0, 0, 0),
      );
      final result = personAI.stepAll([queen], grid);
      // Must move — cannot stay on same tile
      expect(result.length, 1);
      expect(result.first.position, isNot(const Position(0, 0, 0)));
    });

    test(
      'removes a person whose tile disappeared with no movable neighbor',
      () {
        // Person at (0,0,0) on an empty tile (was cleared by combination).
        // All neighbors within bounds are empty → cannot move → drowns.
        var grid = Grid.empty();
        final person = Person(
          id: 1,
          type: const RegularTile(1),
          position: const Position(0, 0, 0),
        );
        final result = personAI.stepAll([person], grid);
        expect(result, isEmpty);
      },
    );

    test('keeps a person on a walkable tile even with no movable neighbor', () {
      // Person at (0,0,0) on a regular tile. All neighbors are empty
      // → cannot move. But tile is intact → stays put.
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(5));
      final person = Person(
        id: 1,
        type: const RegularTile(1),
        position: const Position(0, 0, 0),
      );
      final result = personAI.stepAll([person], grid);
      expect(result.length, 1);
      expect(result.first.position, const Position(0, 0, 0));
    });

    test('does not place two persons on the same cell', () {
      var grid = Grid.empty();
      grid = grid.setCell(const Position(0, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 0, 0), const RegularTile(1));
      grid = grid.setCell(const Position(0, 1, 0), const RegularTile(1));
      grid = grid.setCell(const Position(1, 1, 0), const RegularTile(1));
      final person1 = Person(
        id: 1,
        type: const RegularTile(1),
        position: const Position(0, 0, 0),
      );
      final person2 = Person(
        id: 2,
        type: const RegularTile(1),
        position: const Position(0, 0, 0),
      );
      final result = personAI.stepAll([person1, person2], grid);
      final positions = result.map((p) => p.position).toSet();
      expect(positions.length, result.length);
    });
  });
}
