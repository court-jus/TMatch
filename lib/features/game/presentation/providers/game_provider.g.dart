// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameRepositoryHash() => r'7f5e0fd33cb7aa9e60bb2aef0610439e98d611fd';

/// See also [gameRepository].
@ProviderFor(gameRepository)
final gameRepositoryProvider = Provider<GameRepository>.internal(
  gameRepository,
  name: r'gameRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameRepositoryRef = ProviderRef<GameRepository>;
String _$gameNotifierHash() => r'4624d1366b07664747563c439535e16697fbe54a';

/// See also [GameNotifier].
@ProviderFor(GameNotifier)
final gameNotifierProvider =
    AutoDisposeNotifierProvider<GameNotifier, GameState>.internal(
      GameNotifier.new,
      name: r'gameNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameNotifier = AutoDisposeNotifier<GameState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
