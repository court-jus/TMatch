import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/storage/save_storage.dart';

class GameRepository {
  final SaveStorage _storage;

  GameRepository(this._storage);

  List<String> listSaves() => _storage.listSaves();

  void save(String name, GameState state) => _storage.save(name, state);

  GameState? load(String name) => _storage.load(name);

  void delete(String name) => _storage.delete(name);

  String exportSave(String name) => _storage.exportSave(name);

  String importSave(String jsonData) => _storage.importSave(jsonData);
}
