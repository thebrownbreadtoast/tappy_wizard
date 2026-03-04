import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import '../game/physics_config.dart';
import '../game/constants.dart';

/// The player-controlled wizard character.
///
/// Responds to gravity each frame and `flap()` calls.
/// Renders using sprite images based on velocity state.
class Wizard {
  final PhysicsConfig config;
  double x;
  double y;
  double velocity = 0;
  final double width = GameConstants.wizardWidth;
  final double height = GameConstants.wizardHeight;

  /// Sprite images — set externally after loading.
  ui.Image? jumpImage;
  ui.Image? glideImage;
  ui.Image? fallImage;

  Wizard({required this.x, required this.y, required this.config});

  // ── Bounding box ─────────────────────────────────
  Rect get rect => Rect.fromLTWH(x, y, width, height);

  int lives = 1;
  bool isInvincible = false;
  double _invincibilityTimer = 0;

  // ── Actions ──────────────────────────────────────
  void flap() {
    velocity = config.flapForce;
  }

  void triggerInvincibility(double duration) {
    isInvincible = true;
    _invincibilityTimer = duration;
  }

  // ── Update ───────────────────────────────────────
  void update(double dt) {
    velocity += config.gravity * dt;
    if (velocity > GameConstants.defaultMaxFallSpeed) {
      velocity = GameConstants.defaultMaxFallSpeed;
    }
    y += velocity * dt;

    if (isInvincible) {
      _invincibilityTimer -= dt;
      if (_invincibilityTimer <= 0) {
        isInvincible = false;
      }
    }
  }

  /// Pick the right sprite based on current velocity.
  ui.Image? get _currentSprite {
    if (velocity < -100) return jumpImage;
    if (velocity < 150) return glideImage;
    return fallImage;
  }

  // ── Render ───────────────────────────────────────
  void render(ui.Canvas canvas, Size screenSize) {
    // Blinking effect when invincible
    if (isInvincible && (DateTime.now().millisecondsSinceEpoch % 200) < 100) {
      return;
    }

    final double tilt =
        (velocity / GameConstants.defaultMaxFallSpeed).clamp(-1.0, 1.0) *
        (velocity < 0
            ? GameConstants.wizardTiltUp.abs()
            : GameConstants.wizardTiltDown);

    canvas.save();
    canvas.translate(x + width / 2, y + height / 2);
    canvas.rotate(tilt);

    final sprite = _currentSprite;
    if (sprite != null) {
      // Draw the sprite image
      final srcRect = Rect.fromLTWH(
        0,
        0,
        sprite.width.toDouble(),
        sprite.height.toDouble(),
      );
      final dstRect = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );
      canvas.drawImageRect(sprite, srcRect, dstRect, Paint());
    } else {
      // Procedural fallback
      _renderFallback(canvas);
    }

    canvas.restore();
  }

  void _renderFallback(ui.Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF7B2FBE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    final hatPaint = Paint()..color = const Color(0xFF3A0078);
    final hatPath = Path()
      ..moveTo(0, -height / 2 - 14)
      ..lineTo(-width / 3, -height / 2 + 2)
      ..lineTo(width / 3, -height / 2 + 2)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(width * 0.15, -2), 4, eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawCircle(Offset(width * 0.2, -2), 2, pupilPaint);
  }

  // ── Reset ────────────────────────────────────────
  void reset(Size screenSize) {
    x = screenSize.width * GameConstants.wizardStartXFraction;
    y = screenSize.height * GameConstants.wizardStartYFraction;
    velocity = 0;
  }
}
