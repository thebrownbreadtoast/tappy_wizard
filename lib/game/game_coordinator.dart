import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../entities/ground.dart';
import '../entities/pipe_manager.dart';
import '../entities/power_up.dart';
import '../entities/power_up_manager.dart';
import '../entities/wizard.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../services/settings_service.dart';
import '../utils/collision.dart';
import 'game_state.dart';
import 'constants.dart';

/// Coordinates the game loop, entity updates, and state transitions
/// using a [ChangeNotifier] to trigger repaints efficiently.
class GameCoordinator extends ChangeNotifier {
  final ScoreService scoreService;
  final SettingsService settingsService;
  final AudioService audio;

  // ── Entities ─────────────────────────────────────
  final Ground ground = Ground();
  final PowerUpManager powerUps = PowerUpManager();
  late final PipeManager pipes;
  late final Wizard wizard;

  // ── State ────────────────────────────────────────
  GameState state = GameState.menu;
  bool initialized = false;
  bool isPaused = false;
  int lastPowerUpMilestone = 0;
  final List<PowerUpType> powerUpQueue = [];
  int pipesToSkipForNext = 0;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  GameCoordinator({
    required this.scoreService,
    required this.settingsService,
    required this.audio,
  }) {
    pipes = PipeManager(config: settingsService.config);
    wizard = Wizard(x: 0, y: 0, config: settingsService.config);
  }

  void start(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (isPaused) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.1) return;

    _update(dt);
    notifyListeners(); // Triggers CustomPainter repaint
  }

  ui.Size? screenSize;

  void _update(double dt) {
    final size = screenSize;
    if (size == null) return;

    if (!initialized) {
      wizard.reset(size);
      initialized = true;
    }

    if (state == GameState.playing) {
      wizard.update(dt);
      ground.update(dt);
      final spawnedGapY = pipes.update(dt, size);
      powerUps.update(dt, pipes.speed);

      // Handle Queued Power-up Spawning
      if (spawnedGapY != null && powerUpQueue.isNotEmpty) {
        if (pipesToSkipForNext > 0) {
          pipesToSkipForNext--;
        } else {
          powerUps.spawnAtY(size, powerUpQueue.removeAt(0), spawnedGapY);
          if (powerUpQueue.isNotEmpty) {
            pipesToSkipForNext = Random().nextInt(3) + 1;
          }
        }
      }

      // Power-up Milestone Check
      final currentScore = scoreService.score;
      if (currentScore > 0 &&
          currentScore % 10 == 0 &&
          currentScore != lastPowerUpMilestone) {
        lastPowerUpMilestone = currentScore;
        _rollForPowerUp(size);
      }

      // Collection check
      for (final pu in powerUps.powerUps) {
        if (!pu.collected && CollisionUtil.rectsOverlap(wizard.rect, pu.rect)) {
          pu.collected = true;
          _applyPowerUp(pu);
        }
      }

      // Score check
      for (final pipe in pipes.pipes) {
        if (!pipe.scored && pipe.x + GameConstants.pipeWidth < wizard.x) {
          pipe.scored = true;
          scoreService.increment();
          pipes.applyDifficulty(scoreService.score);
          audio.playScore();
        }
      }

      // Collision: pipes
      if (!wizard.isInvincible) {
        for (final pipe in pipes.pipes) {
          if (CollisionUtil.rectsOverlap(wizard.rect, pipe.topRect) ||
              CollisionUtil.rectsOverlap(wizard.rect, pipe.bottomRect)) {
            _onHit();
            return;
          }
        }
      }

      // Collision: ground & ceiling
      if (wizard.y + wizard.height >=
              size.height - GameConstants.groundHeight ||
          wizard.y <= 0) {
        _onHit();
      }
    }
  }

  void _onHit() {
    if (wizard.lives > 1) {
      wizard.lives--;
      wizard.triggerInvincibility(2.0);
      audio.playHit();
    } else {
      state = GameState.gameOver;
      audio.playHit();
      scoreService.saveHighScore();
      notifyListeners(); // Ensure UI knows state changed
    }
  }

  void _rollForPowerUp(ui.Size size) {
    final randLife = Random().nextDouble();
    final randSpell = Random().nextDouble();
    final initialLength = powerUpQueue.length;

    if (randLife < 0.20) {
      powerUpQueue.add(PowerUpType.extraLife);
    }
    if (randSpell < 0.30) {
      powerUpQueue.add(PowerUpType.magicSpell);
    }

    if (initialLength == 0 && powerUpQueue.isNotEmpty) {
      pipesToSkipForNext = Random().nextInt(5);
    }
  }

  void _applyPowerUp(PowerUp pu) {
    if (pu.type == PowerUpType.extraLife) {
      wizard.lives++;
      audio.playLife();
    } else {
      pipes.removeNextPipes(4);
      audio.playSpell();
    }
  }

  void handleTap() {
    switch (state) {
      case GameState.menu:
        state = GameState.playing;
        wizard.flap();
        audio.playFlap();
        break;
      case GameState.playing:
        wizard.flap();
        audio.playFlap();
        break;
      case GameState.gameOver:
        break;
    }
    notifyListeners();
  }

  void restart() {
    final size = screenSize;
    if (size == null) return;
    wizard.reset(size);
    pipes.reset();
    ground.reset();
    powerUps.reset();
    lastPowerUpMilestone = 0;
    powerUpQueue.clear();
    pipesToSkipForNext = 0;
    scoreService.resetScore();
    state = GameState.menu;
    initialized = false;
    notifyListeners();
  }

  void pause() {
    isPaused = true;
    audio.pauseBgm();
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    audio.resumeBgm();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    wizard.dispose();
    powerUps.dispose();
    super.dispose();
  }
}
