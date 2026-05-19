import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 1;

  @override
  Person read(BinaryReader reader) {
    final id = reader.readInt();
    final type = reader.read() as TileType;
    final x = reader.readInt();
    final y = reader.readInt();
    final z = reader.readInt();
    final stash = reader.read() as TileType?;
    return Person(
      id: id,
      type: type,
      position: Position(x, y, z),
      stash: stash,
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeInt(obj.id)
      ..write(obj.type)
      ..writeInt(obj.position.x)
      ..writeInt(obj.position.y)
      ..writeInt(obj.position.z)
      ..write(obj.stash);
  }
}
