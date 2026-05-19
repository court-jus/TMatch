import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;

  const ScoreDisplay({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Score: $score',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
