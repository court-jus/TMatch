import 'package:flutter/material.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/features/game/presentation/widgets/tile_widget.dart';

class StashDisplay extends StatelessWidget {
  final TileType? stash;
  final VoidCallback onTap;
  final double tileSize;

  const StashDisplay({
    super.key,
    required this.stash,
    required this.onTap,
    this.tileSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final displaySize = tileSize * 0.8;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: displaySize,
        height: displaySize,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: stash != null
            ? TileWidget(tile: stash!)
            : const Icon(Icons.inbox, size: 20),
      ),
    );
  }
}
