import 'dart:collection';

import 'package:tmatch/core/constants/game_constants.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/utils/floor_mapper.dart';
import 'package:tmatch/core/models/grid.dart';

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
  /// [connected] must be the result of [findConnected] at [pos].
  TileType? checkCombination(
    Grid grid,
    List<Position> connected,
    Position pos,
  ) {
    final threshold = GameConstants.matchThreshold(
      FloorMapper.zToVirtualFloor(pos.z),
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
        newValue < -7) {
      return null;
    }
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
