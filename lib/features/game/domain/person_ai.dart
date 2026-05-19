import 'dart:math';

import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/core/models/tile_type.dart';

class PersonAI {
  final Random _random;

  PersonAI(this._random);

  /// Advances one person step. Returns updated persons list.
  List<Person> stepAll(List<Person> persons, Grid grid) {
    final result = <Person>[];

    for (final person in persons) {
      final stepped = _step(person, grid, persons);
      if (stepped != null) {
        result.add(stepped);
      }
    }

    return result;
  }

  Person? _step(Person person, Grid grid, List<Person> allPersons) {
    final movableNeighbors = _neighbors(person.position, grid)
        .where(
          (n) =>
              _isWalkable(grid.getCell(n)) &&
              !_personAt(persons: allPersons, position: n),
        )
        .toList();

    if (movableNeighbors.isNotEmpty) {
      final target = movableNeighbors[_random.nextInt(movableNeighbors.length)];
      return person.copyWith(position: target);
    }

    // Drown only if the tile under the person disappeared
    if (!_isWalkable(grid.getCell(person.position))) return null;

    return person;
  }

  bool _isWalkable(TileType tile) {
    if (tile.isEmpty) return false;
    if (tile.isDiamond) return false;
    if (tile is DoorTile || tile is EnemyTile) {
      return false;
    }
    return true;
  }

  bool _personAt({required List<Person> persons, required Position position}) {
    return persons.any((p) => p.position == position);
  }

  Iterable<Position> _neighbors(Position pos, Grid grid) sync* {
    final dirs = [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
      (-1, -1),
      (-1, 1),
      (1, -1),
      (1, 1), // diagonals
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
