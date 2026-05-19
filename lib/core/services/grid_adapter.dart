import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';

class GridAdapter extends TypeAdapter<Grid> {
  @override
  final int typeId = 2;

  @override
  Grid read(BinaryReader reader) {
    final width = reader.readInt();
    final height = reader.readInt();
    final floors = reader.readInt();
    final cellsLength = reader.readInt();
    final cells = <Position, TileType>{};
    for (var i = 0; i < cellsLength; i++) {
      final x = reader.readInt();
      final y = reader.readInt();
      final z = reader.readInt();
      final type = reader.read() as TileType;
      cells[Position(x, y, z)] = type;
    }
    return Grid(width: width, height: height, floors: floors, cells: cells);
  }

  @override
  void write(BinaryWriter writer, Grid obj) {
    writer
      ..writeInt(obj.width)
      ..writeInt(obj.height)
      ..writeInt(obj.floors)
      ..writeInt(obj.cells.length);
    for (final entry in obj.cells.entries) {
      writer
        ..writeInt(entry.key.x)
        ..writeInt(entry.key.y)
        ..writeInt(entry.key.z)
        ..write(entry.value);
    }
  }
}
