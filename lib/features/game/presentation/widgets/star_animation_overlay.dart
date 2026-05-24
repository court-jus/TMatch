import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmatch/core/constants/game_constants.dart';
import 'package:tmatch/features/game/presentation/models/star_animation_event.dart';
import 'package:tmatch/features/game/presentation/providers/star_animation_provider.dart';

class StarAnimationOverlay extends ConsumerWidget {
  final GlobalKey boardStackKey;
  final GlobalKey scoreKey;
  final GlobalKey mainStackKey;

  const StarAnimationOverlay({
    super.key,
    required this.boardStackKey,
    required this.scoreKey,
    required this.mainStackKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(starAnimationNotifierProvider);
    if (events.isEmpty) return const SizedBox.shrink();

    final mainStackRenderBox =
        mainStackKey.currentContext!.findRenderObject() as RenderBox;
    final boardRenderBox =
        boardStackKey.currentContext!.findRenderObject() as RenderBox;
    final scoreRenderBox =
        scoreKey.currentContext!.findRenderObject() as RenderBox;

    final cellW = GameConstants.cellWidth;
    final cellH = GameConstants.cellHeight;

    return Stack(
      children: events.map((event) {
        final startInBoard = Offset(
          event.tileX * cellW + cellW / 2,
          event.tileY * cellH + cellH / 2,
        );
        final startPos = mainStackRenderBox.globalToLocal(
          boardRenderBox.localToGlobal(startInBoard),
        );
        final scoreCenter = scoreRenderBox.size.center(Offset.zero);
        final endPos = mainStackRenderBox.globalToLocal(
          scoreRenderBox.localToGlobal(scoreCenter),
        );
        return Positioned.fill(
          child: _AnimatedStarGroup(
            key: ValueKey(event.id),
            event: event,
            startPos: startPos,
            endPos: endPos,
            onComplete: () => ref
                .read(starAnimationNotifierProvider.notifier)
                .remove(event.id),
          ),
        );
      }).toList(),
    );
  }
}

class _AnimatedStarGroup extends StatefulWidget {
  final StarAnimationEvent event;
  final Offset startPos;
  final Offset endPos;
  final VoidCallback onComplete;

  const _AnimatedStarGroup({
    super.key,
    required this.event,
    required this.startPos,
    required this.endPos,
    required this.onComplete,
  });

  @override
  State<_AnimatedStarGroup> createState() => _AnimatedStarGroupState();
}

class _AnimatedStarGroupState extends State<_AnimatedStarGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final int _starCount;
  late final double _starSize;
  late final int _totalMs;

  static const _flightMs = 600;
  static const _staggerMs = 50;

  @override
  void initState() {
    super.initState();

    _starCount = widget.event.pointsAwarded >= 1000
        ? widget.event.pointsAwarded ~/ 1000
        : widget.event.pointsAwarded ~/ 100;
    _starSize = widget.event.pointsAwarded >= 1000 ? 80.0 : 50.0;
    _totalMs = _staggerMs * (_starCount - 1) + _flightMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: List.generate(_starCount, (i) {
            final begin = (i * _staggerMs) / _totalMs;
            final end = (i * _staggerMs + _flightMs) / _totalMs;
            final curve = Interval(begin, end, curve: Curves.decelerate);
            final t = curve.transform(_controller.value);

            final dx = widget.endPos.dx - widget.startPos.dx;
            final dy = widget.endPos.dy - widget.startPos.dy;
            final x = widget.startPos.dx + dx * t;
            final y = widget.startPos.dy + dy * t - 40 * sin(t * pi);

            final opacity = t > 0.8 ? (1.0 - (t - 0.8) / 0.2) : 1.0;

            return Positioned(
              left: x - _starSize / 2,
              top: y - _starSize / 2,
              child: Opacity(
                opacity: opacity,
                child: Image.asset('assets/images/Star.png', width: _starSize),
              ),
            );
          }),
        );
      },
    );
  }
}
