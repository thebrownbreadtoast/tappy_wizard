import 'dart:math';
import 'dart:ui' as ui;

import '../game/constants.dart';
import '../game/physics_config.dart';
import 'pipe_pair.dart';

/// Spawns, recycles, and manages all [PipePair] instances.
class PipeManager {
  final PhysicsConfig config;
  final List<PipePair> pipes = [];
  final Random _random = Random();
  double _timeSinceLastSpawn = 0;

  /// Current speed — may increase with difficulty.
  late double speed;

  PipeManager({required this.config}) {
    speed = GameConstants.defaultPipeSpeed;
  }

  // ── Difficulty scaling ───────────────────────────
  void applyDifficulty(int score) {
    speed =
        (GameConstants.defaultPipeSpeed +
                score * GameConstants.speedIncreasePerPoint)
            .clamp(0, GameConstants.maxPipeSpeed);
  }

  // ── Update ───────────────────────────────────────
  double? update(double dt, ui.Size screenSize) {
    _timeSinceLastSpawn += dt;
    double? spawnedGapY;

    // Spawn when interval passes
    if (_timeSinceLastSpawn >= GameConstants.defaultPipeSpawnInterval) {
      _timeSinceLastSpawn = 0;
      spawnedGapY = _spawn(screenSize);
    }

    // Move existing pipes
    for (final pipe in pipes) {
      pipe.update(dt, speed);
    }

    // Remove off-screen pipes
    pipes.removeWhere((p) => p.isOffScreen);

    return spawnedGapY;
  }

  double _spawn(ui.Size screenSize) {
    final double playableHeight =
        screenSize.height - GameConstants.groundHeight;
    final double minCenter =
        GameConstants.pipeMinTopHeight + config.pipeGap / 2;
    final double maxCenter =
        playableHeight - GameConstants.pipeBottomPadding - config.pipeGap / 2;
    final double gapCenter =
        minCenter + _random.nextDouble() * (maxCenter - minCenter);

    pipes.add(
      PipePair(
        x: screenSize.width,
        gapCenterY: gapCenter,
        gap: config.pipeGap,
        screenHeight: screenSize.height,
      ),
    );
    return gapCenter;
  }

  // ── Render ───────────────────────────────────────
  void render(ui.Canvas canvas) {
    for (final pipe in pipes) {
      pipe.render(canvas);
    }
  }

  void reset() {
    pipes.clear();
    _timeSinceLastSpawn = 0;
    speed = GameConstants.defaultPipeSpeed;
  }

  /// Removes the specified number of pipes that are ahead of the wizard.
  void removeNextPipes(int count) {
    int removed = 0;
    // Remove pipes that are still to the right of the wizard's typical X position
    pipes.removeWhere((p) {
      if (removed < count && p.x > 0) {
        removed++;
        return true;
      }
      return false;
    });
  }
}
