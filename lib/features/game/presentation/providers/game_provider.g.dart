// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameRepositoryHash() => r'919180b571ebae7efbe460b1e09852ad82c737d3';

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
String _$gameNotifierHash() => r'0a516121fcdea7bb2a9a1827610477d608c6f31d';

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
