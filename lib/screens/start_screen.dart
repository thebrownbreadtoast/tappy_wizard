import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'settings_screen.dart';

/// Full-screen overlay shown before the game starts.
class StartScreen extends StatelessWidget {
  final int highScore;
  final VoidCallback onStart;
  final SettingsService settingsService;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onCloseSettings;

  const StartScreen({
    super.key,
    required this.highScore,
    required this.onStart,
    required this.settingsService,
    this.onOpenSettings,
    this.onCloseSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onStart,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black54,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  '🧙 Tappy Wizard',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.purpleAccent, blurRadius: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Tap prompt
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (_, opacity, child) =>
                      Opacity(opacity: opacity, child: child),
                  child: const Text(
                    'Tap to Start',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // High score
                if (highScore > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '🏆  Best: $highScore',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Settings Button
        Positioned(
          top: 60,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 32),
              onPressed: () async {
                onOpenSettings?.call();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SettingsScreen(settingsService: settingsService),
                  ),
                );
                onCloseSettings?.call();
              },
            ),
          ),
        ),
      ],
    );
  }
}
