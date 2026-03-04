import 'package:flutter/material.dart';

/// In-game heads-up display showing the current score.
class Hud extends StatelessWidget {
  final int score;

  const Hud({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 48,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          '$score',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
              const Shadow(color: Colors.purpleAccent, blurRadius: 16),
            ],
          ),
        ),
      ),
    );
  }
}
