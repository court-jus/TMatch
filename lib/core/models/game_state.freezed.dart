// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameState {
  Grid get grid => throw _privateConstructorUsedError;
  List<Person> get persons => throw _privateConstructorUsedError;
  Map<int, TileType?> get stashes => throw _privateConstructorUsedError;
  TileType get currentTile => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get currentFloor => throw _privateConstructorUsedError;
  int? get selectedPersonId => throw _privateConstructorUsedError;
  bool get isGameOver => throw _privateConstructorUsedError;
  GameOverReason? get gameOverReason => throw _privateConstructorUsedError;
  int get step => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    Grid grid,
    List<Person> persons,
    Map<int, TileType?> stashes,
    TileType currentTile,
    int score,
    int currentFloor,
    int? selectedPersonId,
    bool isGameOver,
    GameOverReason? gameOverReason,
    int step,
  });

  $GridCopyWith<$Res> get grid;
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grid = null,
    Object? persons = null,
    Object? stashes = null,
    Object? currentTile = null,
    Object? score = null,
    Object? currentFloor = null,
    Object? selectedPersonId = freezed,
    Object? isGameOver = null,
    Object? gameOverReason = freezed,
    Object? step = null,
  }) {
    return _then(
      _value.copyWith(
            grid: null == grid
                ? _value.grid
                : grid // ignore: cast_nullable_to_non_nullable
                      as Grid,
            persons: null == persons
                ? _value.persons
                : persons // ignore: cast_nullable_to_non_nullable
                      as List<Person>,
            stashes: null == stashes
                ? _value.stashes
                : stashes // ignore: cast_nullable_to_non_nullable
                      as Map<int, TileType?>,
            currentTile: null == currentTile
                ? _value.currentTile
                : currentTile // ignore: cast_nullable_to_non_nullable
                      as TileType,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            currentFloor: null == currentFloor
                ? _value.currentFloor
                : currentFloor // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedPersonId: freezed == selectedPersonId
                ? _value.selectedPersonId
                : selectedPersonId // ignore: cast_nullable_to_non_nullable
                      as int?,
            isGameOver: null == isGameOver
                ? _value.isGameOver
                : isGameOver // ignore: cast_nullable_to_non_nullable
                      as bool,
            gameOverReason: freezed == gameOverReason
                ? _value.gameOverReason
                : gameOverReason // ignore: cast_nullable_to_non_nullable
                      as GameOverReason?,
            step: null == step
                ? _value.step
                : step // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridCopyWith<$Res> get grid {
    return $GridCopyWith<$Res>(_value.grid, (value) {
      return _then(_value.copyWith(grid: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Grid grid,
    List<Person> persons,
    Map<int, TileType?> stashes,
    TileType currentTile,
    int score,
    int currentFloor,
    int? selectedPersonId,
    bool isGameOver,
    GameOverReason? gameOverReason,
    int step,
  });

  @override
  $GridCopyWith<$Res> get grid;
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grid = null,
    Object? persons = null,
    Object? stashes = null,
    Object? currentTile = null,
    Object? score = null,
    Object? currentFloor = null,
    Object? selectedPersonId = freezed,
    Object? isGameOver = null,
    Object? gameOverReason = freezed,
    Object? step = null,
  }) {
    return _then(
      _$GameStateImpl(
        grid: null == grid
            ? _value.grid
            : grid // ignore: cast_nullable_to_non_nullable
                  as Grid,
        persons: null == persons
            ? _value._persons
            : persons // ignore: cast_nullable_to_non_nullable
                  as List<Person>,
        stashes: null == stashes
            ? _value._stashes
            : stashes // ignore: cast_nullable_to_non_nullable
                  as Map<int, TileType?>,
        currentTile: null == currentTile
            ? _value.currentTile
            : currentTile // ignore: cast_nullable_to_non_nullable
                  as TileType,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        currentFloor: null == currentFloor
            ? _value.currentFloor
            : currentFloor // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedPersonId: freezed == selectedPersonId
            ? _value.selectedPersonId
            : selectedPersonId // ignore: cast_nullable_to_non_nullable
                  as int?,
        isGameOver: null == isGameOver
            ? _value.isGameOver
            : isGameOver // ignore: cast_nullable_to_non_nullable
                  as bool,
        gameOverReason: freezed == gameOverReason
            ? _value.gameOverReason
            : gameOverReason // ignore: cast_nullable_to_non_nullable
                  as GameOverReason?,
        step: null == step
            ? _value.step
            : step // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$GameStateImpl implements _GameState {
  const _$GameStateImpl({
    required this.grid,
    required final List<Person> persons,
    required final Map<int, TileType?> stashes,
    required this.currentTile,
    required this.score,
    required this.currentFloor,
    required this.selectedPersonId,
    required this.isGameOver,
    required this.gameOverReason,
    required this.step,
  }) : _persons = persons,
       _stashes = stashes;

  @override
  final Grid grid;
  final List<Person> _persons;
  @override
  List<Person> get persons {
    if (_persons is EqualUnmodifiableListView) return _persons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_persons);
  }

  final Map<int, TileType?> _stashes;
  @override
  Map<int, TileType?> get stashes {
    if (_stashes is EqualUnmodifiableMapView) return _stashes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stashes);
  }

  @override
  final TileType currentTile;
  @override
  final int score;
  @override
  final int currentFloor;
  @override
  final int? selectedPersonId;
  @override
  final bool isGameOver;
  @override
  final GameOverReason? gameOverReason;
  @override
  final int step;

  @override
  String toString() {
    return 'GameState(grid: $grid, persons: $persons, stashes: $stashes, currentTile: $currentTile, score: $score, currentFloor: $currentFloor, selectedPersonId: $selectedPersonId, isGameOver: $isGameOver, gameOverReason: $gameOverReason, step: $step)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.grid, grid) || other.grid == grid) &&
            const DeepCollectionEquality().equals(other._persons, _persons) &&
            const DeepCollectionEquality().equals(other._stashes, _stashes) &&
            (identical(other.currentTile, currentTile) ||
                other.currentTile == currentTile) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.currentFloor, currentFloor) ||
                other.currentFloor == currentFloor) &&
            (identical(other.selectedPersonId, selectedPersonId) ||
                other.selectedPersonId == selectedPersonId) &&
            (identical(other.isGameOver, isGameOver) ||
                other.isGameOver == isGameOver) &&
            (identical(other.gameOverReason, gameOverReason) ||
                other.gameOverReason == gameOverReason) &&
            (identical(other.step, step) || other.step == step));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    grid,
    const DeepCollectionEquality().hash(_persons),
    const DeepCollectionEquality().hash(_stashes),
    currentTile,
    score,
    currentFloor,
    selectedPersonId,
    isGameOver,
    gameOverReason,
    step,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);
}

abstract class _GameState implements GameState {
  const factory _GameState({
    required final Grid grid,
    required final List<Person> persons,
    required final Map<int, TileType?> stashes,
    required final TileType currentTile,
    required final int score,
    required final int currentFloor,
    required final int? selectedPersonId,
    required final bool isGameOver,
    required final GameOverReason? gameOverReason,
    required final int step,
  }) = _$GameStateImpl;

  @override
  Grid get grid;
  @override
  List<Person> get persons;
  @override
  Map<int, TileType?> get stashes;
  @override
  TileType get currentTile;
  @override
  int get score;
  @override
  int get currentFloor;
  @override
  int? get selectedPersonId;
  @override
  bool get isGameOver;
  @override
  GameOverReason? get gameOverReason;
  @override
  int get step;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
