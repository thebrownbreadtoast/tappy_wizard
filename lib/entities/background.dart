import 'dart:math';
import 'package:flutter/painting.dart';
import '../game/constants.dart';

/// Parallax scrolling background with gradient sky and cloud-like shapes.
class Background {
  double _offset1 = 0;
  double _offset2 = 0;
  final List<_Cloud> _clouds = [];
  bool _initialized = false;

  void _initClouds(Size size) {
    if (_initialized) return;
    _initialized = true;
    final rng = Random(42); // deterministic
    for (int i = 0; i < 6; i++) {
      _clouds.add(
        _Cloud(
          x: rng.nextDouble() * size.width,
          y: 30 + rng.nextDouble() * (size.height * 0.35),
          width: 60 + rng.nextDouble() * 80,
          height: 20 + rng.nextDouble() * 20,
          speed:
              GameConstants.bgLayerSpeed1 +
              rng.nextDouble() *
                  (GameConstants.bgLayerSpeed2 - GameConstants.bgLayerSpeed1),
        ),
      );
    }
  }

  void update(double dt, Size size) {
    _initClouds(size);
    _offset1 += GameConstants.bgLayerSpeed1 * dt;
    _offset2 += GameConstants.bgLayerSpeed2 * dt;

    for (final cloud in _clouds) {
      cloud.x -= cloud.speed * dt;
      if (cloud.x + cloud.width < 0) {
        cloud.x = size.width + cloud.width;
      }
    }
  }

  void render(Canvas canvas, Size size) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A237E), // deep indigo
          Color(0xFF4A148C), // purple
          Color(0xFFFF8A65), // sunset orange
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Stars (far layer)
    _drawStars(canvas, size);

    // Clouds
    for (final cloud in _clouds) {
      final cloudPaint = Paint()..color = const Color(0x33FFFFFF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cloud.x, cloud.y, cloud.width, cloud.height),
          Radius.circular(cloud.height / 2),
        ),
        cloudPaint,
      );
    }

    // Distant hills (near layer)
    _drawHills(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()..color = const Color(0x88FFFFFF);
    final rng = Random(7);
    for (int i = 0; i < 30; i++) {
      final sx = (rng.nextDouble() * size.width - _offset1) % size.width;
      final sy = rng.nextDouble() * size.height * 0.45;
      canvas.drawCircle(Offset(sx, sy), 1.2, starPaint);
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final hillPaint = Paint()..color = const Color(0xFF1B3A2D);
    final path = Path();
    final double baseY = size.height - GameConstants.groundHeight;
    path.moveTo(0, baseY);
    for (double x = 0; x <= size.width; x += 1) {
      final adjustedX = x + _offset2;
      final y =
          baseY -
          20 * sin(adjustedX * 0.015) -
          12 * sin(adjustedX * 0.03 + 1.5);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, baseY);
    path.close();
    canvas.drawPath(path, hillPaint);
  }

  void reset() {
    _offset1 = 0;
    _offset2 = 0;
    _initialized = false;
    _clouds.clear();
  }
}

class _Cloud {
  double x;
  double y;
  double width;
  double height;
  double speed;

  _Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
  });
}
