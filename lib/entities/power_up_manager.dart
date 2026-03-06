import 'dart:math';
import 'dart:ui' as ui;
import 'power_up.dart';

class PowerUpManager {
  final List<PowerUp> powerUps = [];
  final Random _random = Random();

  ui.Image? lifeImage;
  ui.Image? spellImage;

  void update(double dt, double speed) {
    for (var pu in powerUps) {
      pu.update(dt, speed);
    }
    powerUps.removeWhere((pu) => pu.isOffScreen || pu.collected);
  }

  void spawn(ui.Size screenSize, PowerUpType type) {
    final double y = 100 + _random.nextDouble() * (screenSize.height - 200);
    spawnAtY(screenSize, type, y);
  }

  void spawnAtY(ui.Size screenSize, PowerUpType type, double y) {
    powerUps.add(
      PowerUp(
        x: screenSize.width,
        y: y - 16, // center the 32x32 powerup on the Y coordinate
        type: type,
      ),
    );
  }

  void render(ui.Canvas canvas) {
    for (var pu in powerUps) {
      final img = pu.type == PowerUpType.extraLife ? lifeImage : spellImage;
      pu.render(canvas, img);
    }
  }

  void reset() {
    powerUps.clear();
  }

  void dispose() {
    lifeImage?.dispose();
    spellImage?.dispose();
  }
}
