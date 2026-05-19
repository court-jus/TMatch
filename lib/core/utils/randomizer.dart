import 'dart:math';

import 'package:tmatch/core/models/tile_type.dart';

class Randomizer {
  final Random _random;

  const Randomizer(this._random);

  factory Randomizer.newSeed() => Randomizer(Random());

  TileType next({bool forMapFill = false}) {
    final i = _random.nextDouble() * 100;
    if (i > 99) return const RegularTile(4);
    if (i > 98 && !forMapFill) return const DoorTile();
    if (i > 96) return const RegularTile(3);
    if (i > 94 && !forMapFill) return const StarTile();
    if (i > 90 && !forMapFill) return const KeyTile();
    if (i > 83) return const EnemyTile();
    if (i > 52) return const RegularTile(2);
    return const RegularTile(1);
  }
}
