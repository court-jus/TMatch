import 'package:flutter/material.dart';
import 'package:tmatch/core/models/tile_type.dart';

class TileWidget extends StatelessWidget {
  final TileType tile;

  const TileWidget({super.key, required this.tile});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      tile.assetPath,
      fit: BoxFit.fitWidth,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: Center(child: Text(tile.value.toString())),
        );
      },
    );
  }
}
