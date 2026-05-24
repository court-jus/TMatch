import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/storage/save_storage.dart';

class WebSaveStorage with SaveStorageSerialization implements SaveStorage {
  final SharedPreferences _prefs;

  static const _listKey = 'save_list';

  WebSaveStorage(this._prefs);

  @override
  List<String> listSaves() {
    final raw = _prefs.getString(_listKey);
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',');
  }

  @override
  void save(String name, GameState state) {
    _prefs.setString(_saveKey(name), jsonEncode(encodeSaveData(name, state)));
    _addToList(name);
  }

  @override
  GameState? load(String name) {
    final raw = _prefs.getString(_saveKey(name));
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return deserializeGameState(data);
  }

  @override
  void delete(String name) {
    _prefs.remove(_saveKey(name));
    _removeFromList(name);
  }

  @override
  String exportSave(String name) {
    return _prefs.getString(_saveKey(name)) ?? '';
  }

  @override
  String importSave(String jsonData) {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;
    final savename = data['savename'] as String;
    _prefs.setString(_saveKey(savename), jsonData);
    _addToList(savename);
    return savename;
  }

  void _addToList(String name) {
    final list = _readList();
    if (!list.contains(name)) {
      list.add(name);
      _prefs.setString(_listKey, list.join(','));
    }
  }

  void _removeFromList(String name) {
    final list = _readList();
    list.remove(name);
    _prefs.setString(_listKey, list.join(','));
  }

  List<String> _readList() {
    final raw = _prefs.getString(_listKey);
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',');
  }

  String _saveKey(String name) => 'save_$name';
}
