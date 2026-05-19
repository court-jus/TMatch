import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/tile_type.dart';

part 'game_state.freezed.dart';

enum GameOverReason { gridFull, allPersonsLost, noValidPlacement }

@freezed
class GameState with _$GameState {
  const factory GameState({
    required Grid grid,
    required List<Person> persons,
    required Map<int, TileType?> stashes,
    required TileType currentTile,
    required int score,
    required int currentFloor,
    required int? selectedPersonId,
    required bool isGameOver,
    required GameOverReason? gameOverReason,
    required int step,
  }) = _GameState;

  factory GameState.initial() => GameState(
    grid: Grid.empty(),
    persons: [],
    stashes: {},
    currentTile: const EmptyTile(),
    score: 0,
    currentFloor: 0,
    selectedPersonId: null,
    isGameOver: false,
    gameOverReason: null,
    step: 0,
  );
}
