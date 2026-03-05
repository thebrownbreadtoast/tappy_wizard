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
  final bool bgmMuted;
  final VoidCallback onToggleBgm;

  const StartScreen({
    super.key,
    required this.highScore,
    required this.onStart,
    required this.settingsService,
    required this.bgmMuted,
    required this.onToggleBgm,
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
                Text(
                  'Tappy Wizard',
                  style: const TextStyle(
                    fontFamily: 'MagicSchoolOne',
                    fontSize: 64,
                    letterSpacing: 6.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    // shadows: [
                    //   const Shadow(color: Colors.purpleAccent, blurRadius: 24),
                    // ],
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
                  child: Text(
                    'Tap to Start',
                    style: const TextStyle(
                      fontFamily: 'MagicSchoolOne',
                      fontSize: 28,
                      letterSpacing: 2.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.white30, blurRadius: 20)],
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
                        fontFamily: 'MagicSchoolOne',
                        fontSize: 22,
                        letterSpacing: 1.5,
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Settings and Mute Buttons
        Positioned(
          top: 60,
          right: 24,
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    bgmMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: onToggleBgm,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
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
            ],
          ),
        ),
      ],
    );
  }
}
