abstract final class GameConstants {
  static const int gridWidth = 6;
  static const int gridHeight = 6;
  static const int initialFloors = 1;
  static const double cellWidth = 100;
  static const double cellHeight = 80;
  static const double leftShift = 121;
  static const double bottomShift = 10;
  static const double mapFillPercent = 0.5;

  static const double tileImageWidth = 101;
  static const double tileImageHeight = 171;
  static const double tileTransparentTop = 50;
  static double get tileScale => cellWidth / tileImageWidth;
  static double get scaledTransparentTop => tileTransparentTop * tileScale;
  static double get scaledVisibleHeight =>
      (tileImageHeight - tileTransparentTop) * tileScale;

  static int matchThreshold(int virtualFloor) => 2 + virtualFloor.abs();

  static const int maxRegularType = 7;

  static const double bugVerticalOffset = 15;

  static const double maxGridScale = 1.8;
  static const double topBarTileRatio = 0.5;
}
