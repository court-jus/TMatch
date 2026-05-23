import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmatch/core/constants/game_constants.dart';
import 'package:tmatch/core/models/game_state.dart';
import 'package:tmatch/core/models/person.dart';
import 'package:tmatch/core/models/tile_type.dart';
import 'package:tmatch/features/game/presentation/providers/game_provider.dart';
import 'package:tmatch/features/game/presentation/widgets/current_tile_display.dart';
import 'package:tmatch/features/game/presentation/widgets/game_board.dart';
import 'package:tmatch/features/game/presentation/widgets/floor_switcher.dart';
import 'package:tmatch/features/game/presentation/widgets/person_widget.dart';
import 'package:tmatch/features/game/presentation/widgets/score_display.dart';
import 'package:tmatch/features/game/presentation/widgets/stash_display.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  currentTile: gameState.currentTile,
                  score: gameState.score,
                  onStashTap: notifier.swapWithStash,
                  persons: gameState.persons,
                  selectedPersonId: gameState.selectedPersonId,
                  stashes: gameState.stashes,
                  onPersonTap: (id) => notifier.selectPerson(id),
                ),
                Expanded(
                  child: GameBoard(
                    grid: gameState.grid,
                    currentFloor: gameState.currentFloor,
                    persons: gameState.persons,
                    stashes: gameState.stashes,
                    selectedPersonId: gameState.selectedPersonId,
                    onTileTap: (x, y) => notifier.placeTile(x, y),
                    onPersonTap: (id) => notifier.selectPerson(id),
                  ),
                ),
                _BottomBar(
                  floorCount: gameState.grid.floors,
                  currentFloor: gameState.currentFloor,
                  onFloorUp: () => notifier.switchFloor(1),
                  onFloorDown: () => notifier.switchFloor(-1),
                  onSave: () => _showSaveDialog(context, ref),
                  onLoad: () => _showSaveListDialog(context, ref),
                ),
              ],
            ),
            if (gameState.isGameOver)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _gameOverReasonText(gameState.gameOverReason),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Final Score: ${gameState.score}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: notifier.newGame,
                        child: const Text('New Game'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save game'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Save name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      ref.read(gameNotifierProvider.notifier).saveGame(name);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved as "$name"')));
      }
    }
  }

  Future<void> _showSaveListDialog(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final saves = notifier.listSaves();

    if (saves.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No saves available')));
      return;
    }

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load game'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: saves.length,
            itemBuilder: (context, index) {
              final saveName = saves[index];
              return ListTile(
                title: Text(saveName),
                onTap: () => Navigator.pop(context, saveName),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (name != null) {
      final success = await notifier.loadSave(name);
      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load save file')),
        );
      }
    }
  }
}

class _TopBar extends StatelessWidget {
  final TileType currentTile;
  final int score;
  final VoidCallback onStashTap;
  final List<Person> persons;
  final int? selectedPersonId;
  final Map<int, TileType?> stashes;
  final void Function(int id) onPersonTap;

  const _TopBar({
    required this.currentTile,
    required this.score,
    required this.onStashTap,
    required this.persons,
    required this.selectedPersonId,
    required this.stashes,
    required this.onPersonTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardScale =
            (constraints.maxWidth /
                    (GameConstants.cellWidth * GameConstants.gridWidth))
                .clamp(0.0, GameConstants.maxGridScale);
        final tileSize =
            GameConstants.cellWidth *
            boardScale *
            GameConstants.topBarTileRatio;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CurrentTileDisplay(currentTile: currentTile, tileSize: tileSize),
              const SizedBox(width: 8),
              if (persons.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: tileSize,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: persons.length,
                      itemBuilder: (context, index) {
                        final person = persons[index];
                        final isSelected = person.id == selectedPersonId;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => onPersonTap(person.id),
                              child: Container(
                                width: tileSize,
                                height: tileSize,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: PersonWidget(tile: person.type),
                              ),
                            ),
                            if (isSelected)
                              StashDisplay(
                                stash: stashes[person.id],
                                onTap: onStashTap,
                                tileSize: tileSize,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ScoreDisplay(score: score),
            ],
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int floorCount;
  final int currentFloor;
  final VoidCallback onFloorUp;
  final VoidCallback onFloorDown;
  final VoidCallback onSave;
  final VoidCallback onLoad;

  const _BottomBar({
    required this.floorCount,
    required this.currentFloor,
    required this.onFloorUp,
    required this.onFloorDown,
    required this.onSave,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          FloorSwitcher(
            currentFloor: currentFloor,
            floorCount: floorCount,
            onFloorUp: onFloorUp,
            onFloorDown: onFloorDown,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.save, size: 20),
            onPressed: onSave,
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, size: 20),
            onPressed: onLoad,
            tooltip: 'Load',
          ),
        ],
      ),
    );
  }
}

String _gameOverReasonText(GameOverReason? reason) {
  switch (reason) {
    case GameOverReason.gridFull:
      return 'The main floor is completely full!';
    case GameOverReason.allPersonsLost:
      return 'All persons have drowned!';
    case GameOverReason.noValidPlacement:
      return 'No valid moves remaining!';
    case null:
      return '';
  }
}
