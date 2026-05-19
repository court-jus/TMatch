// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Grid {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  int get floors => throw _privateConstructorUsedError;
  Map<Position, TileType> get cells => throw _privateConstructorUsedError;

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GridCopyWith<Grid> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GridCopyWith<$Res> {
  factory $GridCopyWith(Grid value, $Res Function(Grid) then) =
      _$GridCopyWithImpl<$Res, Grid>;
  @useResult
  $Res call({int width, int height, int floors, Map<Position, TileType> cells});
}

/// @nodoc
class _$GridCopyWithImpl<$Res, $Val extends Grid>
    implements $GridCopyWith<$Res> {
  _$GridCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? floors = null,
    Object? cells = null,
  }) {
    return _then(
      _value.copyWith(
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int,
            floors: null == floors
                ? _value.floors
                : floors // ignore: cast_nullable_to_non_nullable
                      as int,
            cells: null == cells
                ? _value.cells
                : cells // ignore: cast_nullable_to_non_nullable
                      as Map<Position, TileType>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GridImplCopyWith<$Res> implements $GridCopyWith<$Res> {
  factory _$$GridImplCopyWith(
    _$GridImpl value,
    $Res Function(_$GridImpl) then,
  ) = __$$GridImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int width, int height, int floors, Map<Position, TileType> cells});
}

/// @nodoc
class __$$GridImplCopyWithImpl<$Res>
    extends _$GridCopyWithImpl<$Res, _$GridImpl>
    implements _$$GridImplCopyWith<$Res> {
  __$$GridImplCopyWithImpl(_$GridImpl _value, $Res Function(_$GridImpl) _then)
    : super(_value, _then);

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? floors = null,
    Object? cells = null,
  }) {
    return _then(
      _$GridImpl(
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int,
        floors: null == floors
            ? _value.floors
            : floors // ignore: cast_nullable_to_non_nullable
                  as int,
        cells: null == cells
            ? _value._cells
            : cells // ignore: cast_nullable_to_non_nullable
                  as Map<Position, TileType>,
      ),
    );
  }
}

/// @nodoc

class _$GridImpl implements _Grid {
  const _$GridImpl({
    required this.width,
    required this.height,
    required this.floors,
    required final Map<Position, TileType> cells,
  }) : _cells = cells;

  @override
  final int width;
  @override
  final int height;
  @override
  final int floors;
  final Map<Position, TileType> _cells;
  @override
  Map<Position, TileType> get cells {
    if (_cells is EqualUnmodifiableMapView) return _cells;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cells);
  }

  @override
  String toString() {
    return 'Grid(width: $width, height: $height, floors: $floors, cells: $cells)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.floors, floors) || other.floors == floors) &&
            const DeepCollectionEquality().equals(other._cells, _cells));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    width,
    height,
    floors,
    const DeepCollectionEquality().hash(_cells),
  );

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridImplCopyWith<_$GridImpl> get copyWith =>
      __$$GridImplCopyWithImpl<_$GridImpl>(this, _$identity);
}

abstract class _Grid implements Grid {
  const factory _Grid({
    required final int width,
    required final int height,
    required final int floors,
    required final Map<Position, TileType> cells,
  }) = _$GridImpl;

  @override
  int get width;
  @override
  int get height;
  @override
  int get floors;
  @override
  Map<Position, TileType> get cells;

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridImplCopyWith<_$GridImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
