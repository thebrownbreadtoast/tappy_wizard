import 'dart:ui';
import 'package:flutter/painting.dart';
import '../game/physics_config.dart';
import '../game/constants.dart';

/// The player-controlled wizard character.
///
/// Responds to gravity each frame and `flap()` calls.
/// Renders as a coloured placeholder rect (swap for sprite later).
class Wizard {
  final PhysicsConfig config;
  double x;
  double y;
  double velocity = 0;
  final double width = GameConstants.wizardWidth;
  final double height = GameConstants.wizardHeight;

  Wizard({required this.x, required this.y, required this.config});

  // ── Bounding box ─────────────────────────────────
  Rect get rect => Rect.fromLTWH(x, y, width, height);

  // ── Actions ──────────────────────────────────────
  /// Called on each tap — applies upward impulse.
  void flap() {
    velocity = config.flapForce;
  }

  // ── Update ───────────────────────────────────────
  void update(double dt) {
    velocity += config.gravity * dt;
    if (velocity > GameConstants.defaultMaxFallSpeed) {
      velocity = GameConstants.defaultMaxFallSpeed;
    }
    y += velocity * dt;
  }

  // ── Render ───────────────────────────────────────
  void render(Canvas canvas, Size screenSize) {
    // Tilt angle based on velocity
    final double tilt =
        (velocity / GameConstants.defaultMaxFallSpeed).clamp(-1.0, 1.0) *
        (velocity < 0
            ? GameConstants.wizardTiltUp.abs()
            : GameConstants.wizardTiltDown);

    canvas.save();
    canvas.translate(x + width / 2, y + height / 2);
    canvas.rotate(tilt);

    // Body
    final bodyPaint = Paint()..color = const Color(0xFF7B2FBE); // purple
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Hat (triangle)
    final hatPaint = Paint()..color = const Color(0xFF3A0078);
    final hatPath = Path()
      ..moveTo(0, -height / 2 - 14)
      ..lineTo(-width / 3, -height / 2 + 2)
      ..lineTo(width / 3, -height / 2 + 2)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(width * 0.15, -2), 4, eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawCircle(Offset(width * 0.2, -2), 2, pupilPaint);

    canvas.restore();
  }

  // ── Reset ────────────────────────────────────────
  void reset(Size screenSize) {
    x = screenSize.width * GameConstants.wizardStartXFraction;
    y = screenSize.height * GameConstants.wizardStartYFraction;
    velocity = 0;
  }
}
