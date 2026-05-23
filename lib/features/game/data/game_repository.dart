import 'dart:convert';
import 'dart:io';

import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';

class GameRepository {
  final String _saveDir;

  GameRepository(this._saveDir);

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

  void save(String name, GameState state) {
    final file = File('$_saveDir/$name.json');
    file.writeAsStringSync(jsonEncode({
      'savename': name,
      'isTMatchSave': true,
      'grid': _serializeGrid(state.grid),
      'current_type': state.currentTile.value,
      'score': state.score,
      'persons': state.persons.map(_serializePerson).toList(),
      'stashes': _serializeStashes(state.stashes),
      'current_stash': state.selectedPersonId,
      'step': state.step,
      'is_game_over': state.isGameOver,
      'game_over_reason': state.gameOverReason?.name,
    }));
  }

  GameState? load(String name) {
    final file = File('$_saveDir/$name.json');
    if (!file.existsSync()) return null;
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _deserializeGameState(data);
  }

  void delete(String name) {
    final file = File('$_saveDir/$name.json');
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  String exportSave(String name) {
    final file = File('$_saveDir/$name.json');
    return file.readAsStringSync();
  }

  String importSave(String jsonData) {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;
    final savename = data['savename'] as String;
    File('$_saveDir/$savename.json').writeAsStringSync(jsonData);
    return savename;
  }

  Map<String, dynamic> _serializeGrid(Grid grid) {
    final cellsList = <Map<String, dynamic>>[];
    for (final entry in grid.cells.entries) {
      cellsList.add({
        'x': entry.key.x,
        'y': entry.key.y,
        'z': entry.key.z,
        'type': entry.value.value,
      });
    }
    return {
      'width': grid.width,
      'height': grid.height,
      'floors': grid.floors,
      'cells': cellsList,
    };
  }

  Grid _deserializeGrid(Map<String, dynamic> data) {
    final cells = <Position, TileType>{};
    final cellsList = data['cells'] as List;
    for (final cellData in cellsList) {
      final x = cellData['x'] as int;
      final y = cellData['y'] as int;
      final z = cellData['z'] as int;
      final typeValue = cellData['type'] as int;
      cells[Position(x, y, z)] = fromValue(typeValue);
    }
    return Grid(
      width: data['width'] as int,
      height: data['height'] as int,
      floors: data['floors'] as int,
      cells: cells,
    );
  }

  Map<String, dynamic> _serializePerson(Person p) {
    return {
      'id': p.id,
      'type': p.type.value,
      'x': p.position.x,
      'y': p.position.y,
      'z': p.position.z,
      'stash': p.stash?.value,
    };
  }

  Person _deserializePerson(Map<String, dynamic> data) {
    return Person(
      id: data['id'] as int,
      type: fromValue(data['type'] as int),
      position: Position(data['x'] as int, data['y'] as int, data['z'] as int),
      stash: data['stash'] != null ? fromValue(data['stash'] as int) : null,
    );
  }

  Map<String, dynamic> _serializeStashes(Map<int, TileType?> stashes) {
    return stashes.map((key, value) => MapEntry(key.toString(), value?.value));
  }

  Map<int, TileType?> _deserializeStashes(Map<String, dynamic> data) {
    final stashes = <int, TileType?>{};
    for (final entry in data.entries) {
      final key = int.parse(entry.key);
      final value = entry.value;
      stashes[key] = value != null ? fromValue(value as int) : null;
    }
    return stashes;
  }

  GameState _deserializeGameState(Map<String, dynamic> data) {
    return GameState(
      grid: _deserializeGrid(data['grid'] as Map<String, dynamic>),
      currentTile: fromValue(data['current_type'] as int),
      score: data['score'] as int,
      persons: (data['persons'] as List)
          .map((p) => _deserializePerson(p as Map<String, dynamic>))
          .toList(),
      stashes: _deserializeStashes(
        Map<String, dynamic>.from(data['stashes'] as Map),
      ),
      selectedPersonId: data['current_stash'] as int?,
      step: data['step'] as int? ?? 0,
      currentFloor: 0,
      isGameOver: (data['is_game_over'] as bool?) ?? false,
      gameOverReason: (data['game_over_reason'] as String?) != null
          ? GameOverReason.values.byName(data['game_over_reason'] as String)
          : null,
    );
  }
}
