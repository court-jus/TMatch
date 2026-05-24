import 'dart:convert';
import 'dart:io';

import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/storage/save_storage.dart';

class FileSaveStorage with SaveStorageSerialization implements SaveStorage {
  final String _saveDir;

  FileSaveStorage(this._saveDir);

  @override
  List<String> listSaves() {
    final dir = Directory(_saveDir);
    if (!dir.existsSync()) return [];
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();
  }

  @override
  void save(String name, GameState state) {
    final file = File('$_saveDir/$name.json');
    file.writeAsStringSync(jsonEncode(encodeSaveData(name, state)));
  }

  @override
  GameState? load(String name) {
    final file = File('$_saveDir/$name.json');
    if (!file.existsSync()) return null;
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return deserializeGameState(data);
  }

  @override
  void delete(String name) {
    final file = File('$_saveDir/$name.json');
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  @override
  String exportSave(String name) {
    final file = File('$_saveDir/$name.json');
    return file.readAsStringSync();
  }

  @override
  String importSave(String jsonData) {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;
    final savename = data['savename'] as String;
    File('$_saveDir/$savename.json').writeAsStringSync(jsonData);
    return savename;
  }
}
