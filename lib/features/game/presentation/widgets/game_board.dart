import 'package:flutter/material.dart';
import 'package:tmatch/core/constants/game_constants.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/position.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/core/utils/floor_mapper.dart';
import 'package:tmatch/core/models/grid.dart';
import 'package:tmatch/features/game/presentation/widgets/person_widget.dart';
import 'package:tmatch/features/game/presentation/widgets/tile_widget.dart';

class GameBoard extends StatelessWidget {
  final Grid grid;
  final int currentFloor;
  final List<Person> persons;
  final Map<int, TileType?> stashes;
  final int? selectedPersonId;
  final void Function(int x, int y) onTileTap;
  final void Function(int id) onPersonTap;
  final GlobalKey? stackKey;

  const GameBoard({
    super.key,
    required this.grid,
    required this.currentFloor,
    required this.persons,
    required this.stashes,
    this.selectedPersonId,
    required this.onTileTap,
    required this.onPersonTap,
    this.stackKey,
  });

  @override
  Widget build(BuildContext context) {
    final z = FloorMapper.virtualFloorToZ(currentFloor);
    final cellW = GameConstants.cellWidth;
    final cellH = GameConstants.cellHeight;
    final gridW = GameConstants.gridWidth;
    final gridH = GameConstants.gridHeight;
    final naturalWidth = cellW * gridW;
    final naturalHeight =
        (gridH - 1) * cellH + GameConstants.scaledVisibleHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / naturalWidth;
        final scaleY = constraints.maxHeight / naturalHeight;
        final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(
          0.0,
          GameConstants.maxGridScale,
        );
        final scaledWidth = naturalWidth * scale;
        final scaledHeight = naturalHeight * scale;

        return Center(
          child: SizedBox(
            width: scaledWidth,
            height: scaledHeight,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: naturalWidth,
              maxWidth: naturalWidth,
              minHeight: naturalHeight,
              maxHeight: naturalHeight,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: naturalWidth,
                  height: naturalHeight,
                  child: Stack(
                    key: stackKey,
                    clipBehavior: Clip.none,
                    children: [
                      for (int y = 0; y < gridH; y++)
                        for (int x = 0; x < gridW; x++)
                          _buildCell(x, y, z, cellW, cellH),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int x, int y, int z, double cellW, double cellH) {
    final pos = Position(x, y, z);
    final tile = grid.getCell(pos);
    final personHere = persons
        .where(
          (p) => p.position.x == x && p.position.y == y && p.position.z == z,
        )
        .firstOrNull;
    final isBug = tile is EnemyTile;

    return Positioned(
      left: x * cellW,
      top: y * cellH,
      width: cellW,
      height: cellH,
      child: GestureDetector(
        onTap: () {
          if (personHere != null) {
            onPersonTap(personHere.id);
          } else {
            onTileTap(x, y);
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: -GameConstants.scaledTransparentTop,
              width: cellW,
              child: TileWidget(tile: isBug ? const EmptyTile() : tile),
            ),
            if (isBug)
              Positioned(
                left: 0,
                top:
                    -(GameConstants.scaledTransparentTop +
                        GameConstants.bugVerticalOffset *
                            GameConstants.tileScale),
                width: cellW,
                child: TileWidget(tile: tile),
              ),
            if (personHere != null)
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: cellW * 0.4,
                  height: cellH * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: personHere.id == selectedPersonId
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: PersonWidget(tile: personHere.type),
                ),
              ),
            if (personHere != null && stashes[personHere.id] != null)
              _buildBubble(stashes[personHere.id]!, cellW, cellH),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(TileType stashed, double cellW, double cellH) {
    return Positioned(
      right: 0,
      top: -GameConstants.scaledTransparentTop * 0.2,
      width: cellW * 0.45,
      height: cellH * 0.5,
      child: Image.asset(stashed.bubbleAssetPath, fit: BoxFit.contain),
    );
  }
}
