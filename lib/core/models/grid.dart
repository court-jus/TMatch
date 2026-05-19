import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tmatch/core/constants/game_constants.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';

part 'grid.freezed.dart';

@freezed
class Grid with _$Grid {
  const factory Grid({
    required int width,
    required int height,
    required int floors,
    required Map<Position, TileType> cells,
  }) = _Grid;

  factory Grid.empty() => Grid(
    width: GameConstants.gridWidth,
    height: GameConstants.gridHeight,
    floors: GameConstants.initialFloors,
    cells: {},
  );
}

extension GridOps on Grid {
  TileType getCell(Position pos) => cells[pos] ?? const EmptyTile();

  Grid setCell(Position pos, TileType type) {
    final newCells = Map<Position, TileType>.from(cells);
    newCells[pos] = type;
    return copyWith(cells: newCells);
  }

  Grid addFloor() => copyWith(floors: floors + 1);
}
