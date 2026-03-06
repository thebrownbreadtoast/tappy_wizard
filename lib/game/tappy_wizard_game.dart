import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../services/settings_service.dart';
import '../screens/hud.dart';
import '../screens/start_screen.dart';
import '../screens/game_over_screen.dart';
import 'game_state.dart';
import 'game_coordinator.dart';

/// The main game widget. Now light-weight, with logic moved to [GameCoordinator].
class TappyWizardGame extends StatefulWidget {
  final ScoreService scoreService;
  final SettingsService settingsService;

  const TappyWizardGame({
    super.key,
    required this.scoreService,
    required this.settingsService,
  });

  @override
  State<TappyWizardGame> createState() => _TappyWizardGameState();
}

class _TappyWizardGameState extends State<TappyWizardGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AudioService _audio;
  late final GameCoordinator _coordinator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _audio = AudioService();
    _coordinator = GameCoordinator(
      scoreService: widget.scoreService,
      settingsService: widget.settingsService,
      audio: _audio,
    );

    // Initial sync of mute setting
    _audio.isBgmMuted = widget.settingsService.bgmMuted;
    _audio.startBgm();

    _coordinator.start(this);
    _loadImages();
  }

  Future<void> _loadImages() async {
    _coordinator.wizard.jumpImage = await _loadUiImage(
      'assets/images/jump.png',
    );
    _coordinator.wizard.glideImage = await _loadUiImage(
      'assets/images/glide.png',
    );
    _coordinator.wizard.fallImage = await _loadUiImage(
      'assets/images/fall.png',
    );
    _coordinator.powerUps.lifeImage = await _loadUiImage(
      'assets/images/life.png',
    );
    _coordinator.powerUps.spellImage = await _loadUiImage(
      'assets/images/spell.png',
    );
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _coordinator.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _coordinator.pause();
    } else if (state == AppLifecycleState.resumed) {
      _coordinator.resume();
    }
  }

  void _onToggleBgm() {
    setState(() {
      final isMuted = !_audio.isBgmMuted;
      _audio.isBgmMuted = isMuted;
      widget.settingsService.setBgmMuted(isMuted);
      if (isMuted) {
        _audio.stopBgm();
      } else {
        _audio.startBgm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ui.Size(constraints.maxWidth, constraints.maxHeight);
        _coordinator.screenSize = size;

        return GestureDetector(
          onTapDown: (_) => _coordinator.handleTap(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            body: Stack(
              children: [
                // 1. Background image (Static, won't rebuild with game loop)
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background-loop.gif',
                    fit: BoxFit.cover,
                  ),
                ),

                // 2. Game canvas (Repaints driven by GameCoordinator, no Widget rebuilds)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GamePainter(coordinator: _coordinator),
                  ),
                ),

                // 3. Overlays & HUD (Driven by ListenableBuilder)
                ListenableBuilder(
                  listenable: _coordinator,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        // HUD
                        if (_coordinator.state == GameState.playing)
                          Hud(
                            score: widget.scoreService.score,
                            lives: _coordinator.wizard.lives,
                          ),

                        // Menu
                        if (_coordinator.state == GameState.menu)
                          StartScreen(
                            highScore: widget.scoreService.highScore,
                            onStart: _coordinator.handleTap,
                            settingsService: widget.settingsService,
                            bgmMuted: _audio.isBgmMuted,
                            onToggleBgm: _onToggleBgm,
                            onOpenSettings: _coordinator.pause,
                            onCloseSettings: _coordinator.resume,
                          ),

                        // Game Over
                        if (_coordinator.state == GameState.gameOver)
                          GameOverScreen(
                            score: widget.scoreService.score,
                            highScore: widget.scoreService.highScore,
                            isNewHighScore: widget.scoreService.isNewHighScore,
                            onRestart: _coordinator.restart,
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GamePainter extends CustomPainter {
  final GameCoordinator coordinator;

  _GamePainter({required this.coordinator}) : super(repaint: coordinator);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    coordinator.pipes.render(canvas);
    coordinator.powerUps.render(canvas);
    coordinator.ground.render(canvas, size);
    coordinator.wizard.render(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
