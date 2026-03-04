import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;

import '../entities/ground.dart';
import '../entities/pipe_manager.dart';
import '../entities/wizard.dart';
import '../game/constants.dart';
import '../game/game_state.dart';
import '../screens/game_over_screen.dart';
import '../screens/hud.dart';
import '../screens/start_screen.dart';
import '../services/audio_service.dart';
import '../services/input_service.dart';
import '../services/score_service.dart';
import '../utils/collision.dart';

import '../services/settings_service.dart';

/// The master widget that owns the game loop, state, and rendering.
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
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  // ── Entities ─────────────────────────────────────
  final Ground _ground = Ground();
  late final PipeManager _pipes;
  late Wizard _wizard;

  // ── Services ─────────────────────────────────────
  final AudioService _audio = AudioService();

  // ── State ────────────────────────────────────────
  GameState _state = GameState.menu;
  bool _initialized = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pipes = PipeManager(config: widget.settingsService.config);
    _wizard = Wizard(
      x: 0,
      y: 0,
      config: widget.settingsService.config,
    ); // will reset once size is known
    _ticker = createTicker(_onTick)..start();
    _audio.startBgm();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      _resumeGame();
    }
  }

  void _pauseGame() {
    _isPaused = true;
    _audio.pauseBgm();
  }

  void _resumeGame() {
    _isPaused = false;
    _audio.resumeBgm();
  }

  // ── Tick ──────────────────────────────────────────
  void _onTick(Duration elapsed) {
    if (_isPaused) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.1) return; // skip abnormal frames

    setState(() => _update(dt));
  }

  void _update(double dt) {
    final size = _screenSize;
    if (size == null) return;

    // Init positions on the very first frame
    if (!_initialized) {
      _wizard.reset(size);
      _initialized = true;
    }

    // Background is now a static image widget — no update needed.

    if (_state == GameState.playing) {
      _wizard.update(dt);
      _ground.update(dt);
      _pipes.update(dt, size);

      // Score check
      for (final pipe in _pipes.pipes) {
        if (!pipe.scored && pipe.x + GameConstants.pipeWidth < _wizard.x) {
          pipe.scored = true;
          widget.scoreService.increment();
          _pipes.applyDifficulty(widget.scoreService.score);
          _audio.playScore();
        }
      }

      // Collision: pipes
      for (final pipe in _pipes.pipes) {
        if (CollisionUtil.rectsOverlap(_wizard.rect, pipe.topRect) ||
            CollisionUtil.rectsOverlap(_wizard.rect, pipe.bottomRect)) {
          _die();
          return;
        }
      }

      // Collision: ground & ceiling
      if (_wizard.y + _wizard.height >=
              size.height - GameConstants.groundHeight ||
          _wizard.y <= 0) {
        _die();
      }
    }
  }

  void _die() {
    _state = GameState.gameOver;
    _audio.playHit();
    widget.scoreService.saveHighScore();
  }

  // ── Input ────────────────────────────────────────
  void _handleTap() {
    switch (_state) {
      case GameState.menu:
        _state = GameState.playing;
        _wizard.flap();
        _audio.playFlap();
        break;
      case GameState.playing:
        _wizard.flap();
        _audio.playFlap();
        break;
      case GameState.gameOver:
        // handled by button on game-over screen
        break;
    }
  }

  void _restart() {
    final size = _screenSize;
    if (size == null) return;
    _wizard.reset(size);
    _pipes.reset();
    _ground.reset();
    widget.scoreService.resetScore();
    _state = GameState.menu;
    _initialized = false;
  }

  // ── Helpers ──────────────────────────────────────
  Size? get _screenSize {
    final box = context.findRenderObject() as RenderBox?;
    return box?.hasSize == true ? box!.size : null;
  }

  // ── Build ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return InputService(
      onTap: _handleTap,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Game canvas (transparent so image shows through)
          Positioned.fill(
            child: CustomPaint(
              painter: _GamePainter(
                ground: _ground,
                pipes: _pipes,
                wizard: _wizard,
                state: _state,
              ),
            ),
          ),

          // HUD
          if (_state == GameState.playing)
            Hud(score: widget.scoreService.score),

          // Overlays
          if (_state == GameState.menu)
            StartScreen(
              highScore: widget.scoreService.highScore,
              onStart: _handleTap,
              settingsService: widget.settingsService,
              onOpenSettings: _pauseGame,
              onCloseSettings: _resumeGame,
            ),

          if (_state == GameState.gameOver)
            GameOverScreen(
              score: widget.scoreService.score,
              highScore: widget.scoreService.highScore,
              isNewHighScore: widget.scoreService.isNewHighScore,
              onRestart: _restart,
            ),
        ],
      ),
    );
  }
}

// ── Custom Painter ──────────────────────────────────
class _GamePainter extends CustomPainter {
  final Ground ground;
  final PipeManager pipes;
  final Wizard wizard;
  final GameState state;

  _GamePainter({
    required this.ground,
    required this.pipes,
    required this.wizard,
    required this.state,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    pipes.render(canvas);
    ground.render(canvas, size);
    // Always draw wizard so player sees it on the menu too
    wizard.render(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
