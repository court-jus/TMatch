import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';

part 'person.freezed.dart';

@freezed
class Person with _$Person {
  const factory Person({
    required int id,
    required TileType type,
    required Position position,
    TileType? stash,
  }) = _Person;
}
