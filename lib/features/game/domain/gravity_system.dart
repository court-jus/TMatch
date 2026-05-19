import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/utils/floor_mapper.dart';
import 'package:tmatch/core/models/grid.dart';

class GravitySystem {
  /// Makes tiles fall down from higher floors to fill empty spaces.
  /// Only applies when virtual floor > 0.
  Grid apply(Grid grid, Position startPos) {
    final virtualFloor = FloorMapper.zToVirtualFloor(startPos.z);
    if (virtualFloor <= 0) return grid;

    var currentZ = startPos.z;
    var result = grid;

    while (currentZ > 0) {
      final pos = Position(startPos.x, startPos.y, currentZ);
      final abovePos = Position(startPos.x, startPos.y, currentZ - 1);

      if (result.getCell(abovePos).isEmpty && !result.getCell(pos).isEmpty) {
        result = result
            .setCell(abovePos, result.getCell(pos))
            .setCell(pos, const EmptyTile());
        currentZ -= 1;
      } else {
        break;
      }
    }

    return result;
  }
}
