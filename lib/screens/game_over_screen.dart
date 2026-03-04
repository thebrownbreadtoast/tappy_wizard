import 'package:flutter/material.dart';

/// Full-screen overlay shown after the wizard crashes.
class GameOverScreen extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback onRestart;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewHighScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Text(
            'Game Over',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
              shadows: [Shadow(color: Colors.red, blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 28),

          // Score card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'SCORE',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '🏆  Best: $highScore',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isNewHighScore) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🎉 New High Score!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Restart button
          ElevatedButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
