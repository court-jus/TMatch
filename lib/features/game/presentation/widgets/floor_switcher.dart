import 'package:flutter/material.dart';

class FloorSwitcher extends StatelessWidget {
  final int currentFloor;
  final int floorCount;
  final VoidCallback onFloorUp;
  final VoidCallback onFloorDown;

  const FloorSwitcher({
    super.key,
    required this.currentFloor,
    required this.floorCount,
    required this.onFloorUp,
    required this.onFloorDown,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up),
          onPressed: onFloorUp,
          tooltip: 'Floor up',
        ),
        Text(
          'Floor ${currentFloor + 1} / $floorCount',
          style: const TextStyle(fontSize: 12),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: onFloorDown,
          tooltip: 'Floor down',
        ),
      ],
    );
  }
}
