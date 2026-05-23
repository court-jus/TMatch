import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmatch/core/constants/game_constants.dart';
import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/services/hive_provider.dart';
import 'package:tmatch/core/utils/floor_mapper.dart';
import 'package:tmatch/core/utils/randomizer.dart';
import 'package:tmatch/features/game/data/game_repository.dart';
import 'package:tmatch/features/game/domain/bug_system.dart';
import 'package:tmatch/features/game/domain/game_engine.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/features/game/domain/person_ai.dart';

part 'game_provider.g.dart';

@riverpod
class GameNotifier extends _$GameNotifier {
  late final GameEngine _engine;
  late final GameRepository _repository;
  late final Randomizer _randomizer;
  late final Random _random;

  @override
  GameState build() {
    _repository = ref.watch(gameRepositoryProvider);
    _random = Random();
    _randomizer = Randomizer.newSeed();
    _engine = GameEngine(
      bugs: BugSystem(_random),
      personAI: PersonAI(_random),
      randomizer: _randomizer,
    );
    newGame();
    return state;
  }

  void newGame() {
    var newState = GameState.initial();
    final (grid, queenPos) = _initializeGrid();

    newState = newState.copyWith(
      grid: grid,
      currentTile: _randomizer.next(),
      persons: [Person(id: 0, type: const PersonTile(9), position: queenPos)],
      selectedPersonId: 0,
    );

    state = newState;
  }

  void placeTile(int x, int y) {
    if (state.isGameOver) return;
    state = _engine.placeTile(state, x, y);
  }

  void swapWithStash() {
    if (state.isGameOver) return;
    final selectedId = state.selectedPersonId;
    if (selectedId == null) {
      return;
    }

    final stashedItem = state.stashes[selectedId];
    final currentTile = state.currentTile;

    final newStashes = Map<int, TileType?>.from(state.stashes)
      ..[selectedId] = currentTile;

    state = state.copyWith(
      stashes: newStashes,
      currentTile: stashedItem ?? _randomizer.next(),
    );

    // Check if the swapped-in tile can be placed
    state = _engine.checkPlacementViability(state);
  }

  void selectPerson(int id) {
    if (state.isGameOver) return;
    state = state.copyWith(selectedPersonId: id);
  }

  void switchFloor(int direction) {
    if (state.isGameOver) return;
    final newFloor = state.currentFloor + direction;
    final maxFloor = FloorMapper.zToVirtualFloor(state.grid.floors - 1);
    final minFloor = 0;

    var clamped = newFloor;
    if (clamped > maxFloor) {
      clamped = minFloor;
    }
    if (clamped < minFloor) {
      clamped = maxFloor;
    }

    state = state.copyWith(currentFloor: clamped);
  }

  List<String> listSaves() {
    return _repository.listSaves();
  }

  Future<bool> loadSave(String name) async {
    final loaded = _repository.load(name);
    if (loaded != null) {
      state = loaded;
      return true;
    }
    return false;
  }

  void saveGame(String name) {
    _repository.save(name, state);
  }

  (Grid, Position) _initializeGrid() {
    var grid = Grid.empty();

    final queenPos = Position(
      _random.nextInt(GameConstants.gridWidth),
      _random.nextInt(GameConstants.gridHeight),
      0,
    );
    grid = grid.setCell(queenPos, const RegularTile(1));
    print('[INIT] queen at ($queenPos) t=1');

    for (var x = 0; x < GameConstants.gridWidth; x++) {
      for (var y = 0; y < GameConstants.gridHeight; y++) {
        if (x == queenPos.x && y == queenPos.y) {
          continue;
        }
        if (_random.nextDouble() < GameConstants.mapFillPercent) {
          final tile = _randomizer.next(forMapFill: true);
          final pos = Position(x, y, 0);
          grid = grid.setCell(pos, tile);
          print('[INIT] ($x, $y, 0) t=${tile.value}');
        }
      }
    }

    return (grid, queenPos);
  }
}

@Riverpod(keepAlive: true)
GameRepository gameRepository(GameRepositoryRef ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return GameRepository(hiveService.savesBox);
}
