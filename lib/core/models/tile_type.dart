sealed class TileType {
  final int value;
  const TileType(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileType &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  String get assetPath;
  String get bubbleAssetPath => '';
  bool get isEmpty => value == 0;
  bool get isRegular => value > 0;
  bool get isSpecial => value < 0 && value > -5;
  bool get isDiamond => value <= -5;
}

final class RegularTile extends TileType {
  const RegularTile(super.value);
  @override
  String get assetPath => switch (value) {
    1 => 'assets/images/Brown Block.png',
    2 => 'assets/images/Dirt Block.png',
    3 => 'assets/images/Grass Block.png',
    4 => 'assets/images/Plain Block.png',
    5 => 'assets/images/Stone Block.png',
    6 => 'assets/images/Wood Block.png',
    7 => 'assets/images/Wall Block.png',
    9 => 'assets/images/queen.png',
    _ => 'assets/images/type_$value.png',
  };
  @override
  String get bubbleAssetPath => switch (value) {
    1 => 'assets/images/Brown Bubble.png',
    2 => 'assets/images/Dirt Bubble.png',
    3 => 'assets/images/Grass Bubble.png',
    4 => 'assets/images/Plain Bubble.png',
    5 => 'assets/images/Stone Bubble.png',
    6 => 'assets/images/Wood Bubble.png',
    7 => 'assets/images/Wall Bubble.png',
    _ => '',
  };
}

final class DoorTile extends SpecialTile {
  const DoorTile() : super(-1);
  @override
  String get assetPath => 'assets/images/Door Tall Closed.png';
  @override
  String get bubbleAssetPath => 'assets/images/Door Tall Bubble.png';
}

final class EnemyTile extends SpecialTile {
  const EnemyTile() : super(-2);
  @override
  String get assetPath => 'assets/images/Enemy Bug.png';
  @override
  String get bubbleAssetPath => 'assets/images/Enemy Bug Bubble.png';
}

final class KeyTile extends SpecialTile {
  const KeyTile() : super(-3);
  @override
  String get assetPath => 'assets/images/Key.png';
  @override
  String get bubbleAssetPath => 'assets/images/Key Bubble.png';
}

final class StarTile extends SpecialTile {
  const StarTile() : super(-4);
  @override
  String get assetPath => 'assets/images/Star.png';
  @override
  String get bubbleAssetPath => 'assets/images/Star Bubble.png';
}

final class SpecialTile extends TileType {
  const SpecialTile(super.value);
  @override
  String get assetPath => switch (value) {
    -1 => 'assets/images/Door Tall Closed.png',
    -2 => 'assets/images/Enemy Bug.png',
    -3 => 'assets/images/Key.png',
    -4 => 'assets/images/Star.png',
    _ => 'assets/images/EmptyNegativeBlock.png',
  };
  @override
  String get bubbleAssetPath => switch (value) {
    -1 => 'assets/images/Door Tall Bubble.png',
    -2 => 'assets/images/Enemy Bug Bubble.png',
    -3 => 'assets/images/Key Bubble.png',
    -4 => 'assets/images/Star Bubble.png',
    _ => '',
  };
}

final class DiamondTile extends TileType {
  const DiamondTile(super.value);
  @override
  String get assetPath => switch (value) {
    -5 => 'assets/images/Green Diamond.png',
    -6 => 'assets/images/Blue Diamond.png',
    -7 => 'assets/images/Orange Diamond.png',
    _ => 'assets/images/EmptyNegativeBlock.png',
  };
  @override
  String get bubbleAssetPath => switch (value) {
    -5 => 'assets/images/Gem Green.png',
    -6 => 'assets/images/Gem Blue.png',
    -7 => 'assets/images/Gem Orange.png',
    _ => '',
  };
}

final class EmptyTile extends TileType {
  const EmptyTile() : super(0);
  @override
  String get assetPath => 'assets/images/Water Block.png';
}

TileType fromValue(int value) => switch (value) {
  0 => const EmptyTile(),
  > 0 => RegularTile(value),
  -1 => const DoorTile(),
  -2 => const EnemyTile(),
  -3 => const KeyTile(),
  -4 => const StarTile(),
  <= -5 => DiamondTile(value),
  _ => throw ArgumentError('Unknown tile value: $value'),
};
