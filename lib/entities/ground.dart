import 'dart:ui';
import '../game/constants.dart';

/// A continuously scrolling ground strip at the bottom of the screen.
class Ground {
  double _offset = 0;

  void update(double dt) {
    _offset += GameConstants.groundSpeed * dt;
    // The ground texture is tiled, so we wrap around at the tile width.
    // We'll use a 48-px tile.
    _offset %= 48;
  }

  void render(Canvas canvas, Size screenSize) {
    final double top = screenSize.height - GameConstants.groundHeight;

    // Main ground fill
    final groundPaint = Paint()..color = const Color(0xFFDEB887); // tan
    canvas.drawRect(
      Rect.fromLTWH(0, top, screenSize.width, GameConstants.groundHeight),
      groundPaint,
    );

    // Grass strip on top
    final grassPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(0, top, screenSize.width, 12), grassPaint);

    // Scrolling dirt lines to show movement
    final linePaint = Paint()
      ..color = const Color(0xFFC8A96E)
      ..strokeWidth = 2;
    for (double x = -_offset; x < screenSize.width; x += 48) {
      canvas.drawLine(Offset(x, top + 20), Offset(x + 24, top + 20), linePaint);
    }
  }

  Rect boundingRect(Size screenSize) {
    return Rect.fromLTWH(
      0,
      screenSize.height - GameConstants.groundHeight,
      screenSize.width,
      GameConstants.groundHeight,
    );
  }

  void reset() {
    _offset = 0;
  }
}
