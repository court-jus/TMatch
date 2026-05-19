import 'package:flutter/material.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/features/game/presentation/widgets/tile_widget.dart';

class CurrentTileDisplay extends StatelessWidget {
  final TileType currentTile;
  final double tileSize;

  const CurrentTileDisplay({
    super.key,
    required this.currentTile,
    this.tileSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Next: ', style: TextStyle(fontSize: 14)),
        SizedBox(
          width: tileSize,
          height: tileSize,
          child: TileWidget(tile: currentTile),
        ),
      ],
    );
  }
}
