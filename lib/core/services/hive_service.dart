import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmatch/core/services/grid_adapter.dart';
import 'package:tmatch/core/services/person_adapter.dart';
import 'package:tmatch/core/services/tile_type_adapter.dart';

class HiveService {
  static const String savesBoxName = 'tmatch_saves';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TileTypeAdapter());
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(GridAdapter());
  }

  Box<Map<String, dynamic>> get savesBox =>
      Hive.box<Map<String, dynamic>>(savesBoxName);
}
