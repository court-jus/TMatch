import 'dart:math';

import 'package:tmatch/core/models/tile_type.dart';

class Randomizer {
  final Random _random;

  const Randomizer(this._random);

  factory Randomizer.newSeed() => Randomizer(Random());

  // Default randomizer:
  // TileType next({bool forMapFill = false}) {
  //   final i = _random.nextDouble() * 100;
  //   if (i > 99) return const RegularTile(4);
  //   if (i > 98 && !forMapFill) return const DoorTile();
  //   if (i > 96) return const RegularTile(3);
  //   if (i > 94 && !forMapFill) return const StarTile();
  //   if (i > 90 && !forMapFill) return const KeyTile();
  //   if (i > 83) return const EnemyTile();
  //   if (i > 52) return const RegularTile(2);
  //   return const RegularTile(1);
  // }

  TileType nextExcluding(Set<int> excludeValues) {
    var tile = next();
    while (excludeValues.contains(tile.value)) {
      tile = next();
    }
    return tile;
  }

  // Debug randomizers:
  // 1. High level tiles:
  // TileType next({bool forMapFill = false}) {
  //   final i = _random.nextDouble() * 100;
  //   if (i > 99) return const RegularTile(4);
  //   if (i > 98 && !forMapFill) return const DoorTile();
  //   if (i > 96) return const RegularTile(3);
  //   if (i > 94 && !forMapFill) return const StarTile();
  //   if (i > 90 && !forMapFill) return const KeyTile();
  //   if (i > 83) return const EnemyTile();
  //   if (i > 10) return const RegularTile(5);
  //   if (i > 2) return const RegularTile(4);
  //   return const RegularTile(3);
  // }

  // 2. Many objects:
  TileType next({bool forMapFill = false}) {
    final i = _random.nextDouble() * 100;
    if (i > 75) return const RegularTile(4);
    if (i > 70 && !forMapFill) return const DoorTile();
    if (i > 62) return const RegularTile(3);
    if (i > 32 && !forMapFill) return const StarTile();
    if (i > 12 && !forMapFill) return const KeyTile();
    if (i > 11) return const EnemyTile();
    if (i > 10) return const RegularTile(5);
    if (i > 2) return const RegularTile(4);
    return const RegularTile(3);
  }
}
