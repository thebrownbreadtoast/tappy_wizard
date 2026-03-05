import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../entities/ground.dart';
import '../entities/pipe_manager.dart';
import '../entities/power_up.dart';
import '../entities/power_up_manager.dart';
import '../entities/wizard.dart';
import '../game/constants.dart';
import '../game/game_state.dart';
import '../screens/game_over_screen.dart';
import '../screens/hud.dart';
import '../screens/start_screen.dart';
import '../services/audio_service.dart';
import '../services/input_service.dart';
import '../services/score_service.dart';
import '../services/settings_service.dart';
import '../utils/collision.dart';

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
  final PowerUpManager _powerUps = PowerUpManager();
  late final PipeManager _pipes;
  late Wizard _wizard;

  // ── Services ─────────────────────────────────────
  final AudioService _audio = AudioService();

  // ── State ────────────────────────────────────────
  GameState _state = GameState.menu;
  bool _initialized = false;
  bool _isPaused = false;
  int _lastPowerUpMilestone = 0;
  final List<PowerUpType> _powerUpQueue = [];
  int _pipesToSkipForNext = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pipes = PipeManager(config: widget.settingsService.config);
    _wizard = Wizard(x: 0, y: 0, config: widget.settingsService.config);
    _ticker = createTicker(_onTick)..start();
    _audio.isBgmMuted = widget.settingsService.bgmMuted;
    _audio.startBgm();
    _loadImages();
  }

  Future<void> _loadImages() async {
    _wizard.jumpImage = await _loadUiImage('assets/images/jump.png');
    _wizard.glideImage = await _loadUiImage('assets/images/glide.png');
    _wizard.fallImage = await _loadUiImage('assets/images/fall.png');
    _powerUps.lifeImage = await _loadUiImage('assets/images/life.png');
    _powerUps.spellImage = await _loadUiImage('assets/images/spell.png');
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

  void _toggleBgm() {
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
      final spawnedGapY = _pipes.update(dt, size);
      _powerUps.update(dt, _pipes.speed);

      // Handle Queued Power-up Spawning
      if (spawnedGapY != null && _powerUpQueue.isNotEmpty) {
        if (_pipesToSkipForNext > 0) {
          _pipesToSkipForNext--;
        } else {
          _powerUps.spawnAtY(size, _powerUpQueue.removeAt(0), spawnedGapY);
          if (_powerUpQueue.isNotEmpty) {
            _pipesToSkipForNext = Random().nextInt(3) + 1; // Skip 1 to 3 pipes
          }
        }
      }

      // Power-up Milestone Check
      final currentScore = widget.scoreService.score;
      if (currentScore > 0 &&
          currentScore % 10 == 0 &&
          currentScore != _lastPowerUpMilestone) {
        _lastPowerUpMilestone = currentScore;
        _rollForPowerUp(size);
      }

      // Collection check
      for (final pu in _powerUps.powerUps) {
        if (!pu.collected &&
            CollisionUtil.rectsOverlap(_wizard.rect, pu.rect)) {
          pu.collected = true;
          _applyPowerUp(pu);
        }
      }

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
      if (!_wizard.isInvincible) {
        for (final pipe in _pipes.pipes) {
          if (CollisionUtil.rectsOverlap(_wizard.rect, pipe.topRect) ||
              CollisionUtil.rectsOverlap(_wizard.rect, pipe.bottomRect)) {
            _onHit();
            return;
          }
        }
      }

      // Collision: ground & ceiling
      if (_wizard.y + _wizard.height >=
              size.height - GameConstants.groundHeight ||
          _wizard.y <= 0) {
        _onHit();
      }
    }
  }

  void _onHit() {
    if (_wizard.lives > 1) {
      _wizard.lives--;
      _wizard.triggerInvincibility(2.0); // 2 seconds of invincibility
      _audio.playHit();
    } else {
      _state = GameState.gameOver;
      _audio.playHit();
      widget.scoreService.saveHighScore();
    }
  }

  void _rollForPowerUp(ui.Size size) {
    final randLife = Random().nextDouble();
    final randSpell = Random().nextDouble();
    final initialLength = _powerUpQueue.length;

    if (randLife < 0.20) {
      _powerUpQueue.add(PowerUpType.extraLife);
    }
    if (randSpell < 0.30) {
      _powerUpQueue.add(PowerUpType.magicSpell);
    }

    if (initialLength == 0 && _powerUpQueue.isNotEmpty) {
      _pipesToSkipForNext = Random().nextInt(5); // 0, 1, 2, 3, or 4
    }
  }

  void _applyPowerUp(PowerUp pu) {
    if (pu.type == PowerUpType.extraLife) {
      if (_wizard.lives < 3) _wizard.lives++;
      _audio.playLife();
    } else {
      _pipes.removeNextPipes(4);
      _audio.playSpell();
    }
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
    _powerUps.reset();
    _lastPowerUpMilestone = 0;
    _powerUpQueue.clear();
    _pipesToSkipForNext = 0;
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
              'assets/images/background-loop.gif',
              fit: BoxFit.cover,
            ),
          ),

          // Game canvas (transparent so image shows through)
          Positioned.fill(
            child: CustomPaint(
              painter: _GamePainter(
                ground: _ground,
                powerUps: _powerUps,
                pipes: _pipes,
                wizard: _wizard,
                state: _state,
              ),
            ),
          ),

          // HUD
          if (_state == GameState.playing)
            Hud(score: widget.scoreService.score, lives: _wizard.lives),

          // Overlays
          if (_state == GameState.menu)
            StartScreen(
              highScore: widget.scoreService.highScore,
              onStart: _handleTap,
              settingsService: widget.settingsService,
              bgmMuted: _audio.isBgmMuted,
              onToggleBgm: _toggleBgm,
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
  final PowerUpManager powerUps;
  final PipeManager pipes;
  final Wizard wizard;
  final GameState state;

  _GamePainter({
    required this.ground,
    required this.powerUps,
    required this.pipes,
    required this.wizard,
    required this.state,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    pipes.render(canvas);
    powerUps.render(canvas);
    ground.render(canvas, size);
    // Always draw wizard so player sees it on the menu too
    wizard.render(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
