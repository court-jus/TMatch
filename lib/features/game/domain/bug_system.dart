import 'dart:collection';
import 'dart:math';

import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/models/grid.dart';

class BugSystem {
  final Random _random;

  BugSystem(this._random);

  /// Returns (updatedGrid, bugsKilledCount, diamondPositions).
  (Grid, int, List<Position>) processAll(Grid grid) {
    var result = grid;
    var totalKilled = 0;
    final diamondPositions = <Position>[];

    final bugPositions = _findAllBugs(result);

    for (final bugPos in bugPositions) {
      // Re-check in case this bug was destroyed by another
      if (result.getCell(bugPos) is! EnemyTile) {
        continue;
      }

      final killCount = _checkBugKill(result, bugPos);
      if (killCount > 0) {
        totalKilled += killCount;
        final (newResult, newPositions) = _convertBugsToDiamond(result, bugPos);
        result = newResult;
        diamondPositions.addAll(newPositions);
      } else {
        result = _moveBug(result, bugPos);
      }
    }

    return (result, totalKilled, diamondPositions);
  }

  List<Position> _findAllBugs(Grid grid) {
    final bugs = <Position>[];
    for (var z = 0; z < grid.floors; z++) {
      for (var x = 0; x < grid.width; x++) {
        for (var y = 0; y < grid.height; y++) {
          final pos = Position(x, y, z);
          final cell = grid.getCell(pos);
          if (cell is EnemyTile) {
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
          if (cell is EnemyTile) {
            queue.add(neighbor);
          }
        }
      }
    }

    return result;
  }

  Grid _moveBug(Grid grid, Position bugPos) {
    final neighbors = _neighbors(
      bugPos,
      grid,
    ).where((n) => grid.getCell(n).isEmpty).toList();

    if (neighbors.isEmpty) return grid;

    final target = neighbors[_random.nextInt(neighbors.length)];
    return grid
        .setCell(target, const EnemyTile())
        .setCell(bugPos, const EmptyTile());
  }

  (Grid, List<Position>) _convertBugsToDiamond(Grid grid, Position bugPos) {
    final connectedBugs = _findConnectedBugs(grid, bugPos);
    var result = grid;
    for (final bp in connectedBugs) {
      result = result.setCell(bp, const DiamondTile(-5));
    }
    return (result, connectedBugs);
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
