import 'package:flutter/material.dart';

/// In-game heads-up display showing the current score.
class Hud extends StatelessWidget {
  final int score;
  final int lives;

  const Hud({super.key, required this.score, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Score (Center)
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontFamily: 'MagicSchoolOne',
                fontSize: 80,
                letterSpacing: 4.0,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  ),
                  // const Shadow(color: Colors.purpleAccent, blurRadius: 16),
                ],
              ),
            ),
          ),
        ),
        // Lives (Top Left)
        Positioned(
          top: 48,
          left: 24,
          child: Row(
            children: List.generate(
              lives,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 28,
                  shadows: [Shadow(color: Colors.white10, blurRadius: 8)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
