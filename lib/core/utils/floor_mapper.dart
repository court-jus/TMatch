abstract final class FloorMapper {
  /// Maps a virtual floor index to a physical z-stack index (now identity).
  static int virtualFloorToZ(int virtualFloor) => virtualFloor;

  /// Inverse of [virtualFloorToZ] (now identity).
  static int zToVirtualFloor(int z) => z;
}
