import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmatch/core/models/tile_type.dart';

class TileTypeAdapter extends TypeAdapter<TileType> {
  @override
  final int typeId = 0;

  @override
  TileType read(BinaryReader reader) {
    final value = reader.readInt();
    return fromValue(value);
  }

  @override
  void write(BinaryWriter writer, TileType obj) {
    writer.writeInt(obj.value);
  }
}
