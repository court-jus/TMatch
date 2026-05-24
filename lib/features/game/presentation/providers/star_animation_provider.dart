import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmatch/features/game/presentation/models/star_animation_event.dart';

part 'star_animation_provider.g.dart';

@riverpod
class StarAnimationNotifier extends _$StarAnimationNotifier {
  int _nextId = 0;

  @override
  List<StarAnimationEvent> build() => [];

  void trigger(int tileX, int tileY, int pointsAwarded) {
    state = [
      ...state,
      StarAnimationEvent(
        id: _nextId++,
        tileX: tileX,
        tileY: tileY,
        pointsAwarded: pointsAwarded,
      ),
    ];
  }

  void remove(int id) {
    state = state.where((e) => e.id != id).toList();
  }

  void clear() {
    state = [];
  }
}
