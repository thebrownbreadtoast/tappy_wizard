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
  Rect get rect => Rect.fromLTWH(
    x + GameConstants.wizardHitboxInset,
    y + GameConstants.wizardHitboxInset,
    width - (GameConstants.wizardHitboxInset * 2),
    height - (GameConstants.wizardHitboxInset * 2),
  );

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

  // ── Render Objects (Reused to prevent pressure) ───
  final ui.Paint _imagePaint = ui.Paint();
  final ui.Paint _bodyPaint = ui.Paint()..color = const Color(0xFF7B2FBE);
  final ui.Paint _hatPaint = ui.Paint()..color = const Color(0xFF3A0078);
  final ui.Paint _eyePaint = ui.Paint()..color = const Color(0xFFFFFFFF);
  final ui.Paint _pupilPaint = ui.Paint()..color = const Color(0xFF000000);

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
      canvas.drawImageRect(sprite, srcRect, dstRect, _imagePaint);
    } else {
      // Procedural fallback
      _renderFallback(canvas);
    }

    canvas.restore();
  }

  void _renderFallback(ui.Canvas canvas) {
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        const Radius.circular(6),
      ),
      _bodyPaint,
    );

    final hatPath = Path()
      ..moveTo(0, -height / 2 - 14)
      ..lineTo(-width / 3, -height / 2 + 2)
      ..lineTo(width / 3, -height / 2 + 2)
      ..close();
    canvas.drawPath(hatPath, _hatPaint);

    canvas.drawCircle(Offset(width * 0.15, -2), 4, _eyePaint);
    canvas.drawCircle(Offset(width * 0.2, -2), 2, _pupilPaint);
  }

  // ── Reset ────────────────────────────────────────
  void reset(Size screenSize) {
    x = screenSize.width * GameConstants.wizardStartXFraction;
    y = screenSize.height * GameConstants.wizardStartYFraction;
    velocity = 0;
  }

  // ── Cleanup ──────────────────────────────────────
  void dispose() {
    jumpImage?.dispose();
    glideImage?.dispose();
    fallImage?.dispose();
  }
}
