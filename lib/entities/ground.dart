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

  // ── Render ───────────────────────────────────────
  void render(Canvas canvas, Size screenSize) {
    final double top = screenSize.height - GameConstants.groundHeight;

    // Main soil fill (Dark brown/earthy)
    final groundPaint = Paint()..color = const Color(0xFF2D1B0D);
    canvas.drawRect(
      Rect.fromLTWH(0, top, screenSize.width, GameConstants.groundHeight),
      groundPaint,
    );

    // Deep Moss/Grass strip on top
    final grassPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRect(Rect.fromLTWH(0, top, screenSize.width, 10), grassPaint);

    // Lighter highlight grass strip
    final highlightGrassPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawRect(
      Rect.fromLTWH(0, top, screenSize.width, 4),
      highlightGrassPaint,
    );

    // Decorative "moss" patches and dirt detail
    final detailPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 3;

    final highlightPaint = Paint()
      ..color = const Color(
        0xFF2E7D32,
      ).withAlpha(76); // ~0.3 opacity (255 * 0.3)

    for (double x = -_offset; x < screenSize.width; x += 48) {
      // Little dirt clusters
      canvas.drawRect(Rect.fromLTWH(x + 10, top + 20, 8, 4), detailPaint);
      canvas.drawRect(Rect.fromLTWH(x + 30, top + 40, 6, 3), detailPaint);

      // Mossy highlights
      canvas.drawRect(Rect.fromLTWH(x + 20, top + 10, 15, 6), highlightPaint);
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
