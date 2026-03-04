import 'dart:ui';
import '../game/constants.dart';

/// A single pair of top + bottom pipe obstacles with a gap between them.
class PipePair {
  double x;
  final double gapCenterY;
  final double gap;
  final double screenHeight;
  bool scored = false;

  PipePair({
    required this.x,
    required this.gapCenterY,
    required this.gap,
    required this.screenHeight,
  });

  // ── Rects ────────────────────────────────────────
  double get _topHeight => gapCenterY - gap / 2;
  double get _bottomTop => gapCenterY + gap / 2;

  Rect get topRect => Rect.fromLTWH(x, 0, GameConstants.pipeWidth, _topHeight);

  Rect get bottomRect => Rect.fromLTWH(
    x,
    _bottomTop,
    GameConstants.pipeWidth,
    screenHeight - _bottomTop,
  );

  // ── Update ───────────────────────────────────────
  void update(double dt, double speed) {
    x -= speed * dt;
  }

  /// `true` when the pipe has scrolled completely off the left edge.
  bool get isOffScreen => x + GameConstants.pipeWidth < 0;

  // ── Render ───────────────────────────────────────
  void render(Canvas canvas) {
    final pipePaint = Paint()..color = const Color(0xFF2ECC71); // main green
    final edgePaint = Paint()
      ..color =
          const Color(0xFF1B5E20) // dark green stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final highlightPaint = Paint()
      ..color = const Color(0x33FFFFFF); // white glow

    // Draw Top Pipe
    canvas.drawRect(topRect, pipePaint);
    canvas.drawRect(topRect, edgePaint);
    canvas.drawRect(Rect.fromLTWH(x + 5, 0, 8, _topHeight), highlightPaint);

    // Top Pipe Cap
    final topCapRect = Rect.fromLTWH(
      x - 4,
      _topHeight - 24,
      GameConstants.pipeWidth + 8,
      24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topCapRect, const Radius.circular(4)),
      pipePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topCapRect, const Radius.circular(4)),
      edgePaint,
    );

    // Draw Bottom Pipe
    canvas.drawRect(bottomRect, pipePaint);
    canvas.drawRect(bottomRect, edgePaint);
    canvas.drawRect(
      Rect.fromLTWH(x + 5, _bottomTop, 8, screenHeight - _bottomTop),
      highlightPaint,
    );

    // Bottom Pipe Cap
    final bottomCapRect = Rect.fromLTWH(
      x - 4,
      _bottomTop,
      GameConstants.pipeWidth + 8,
      24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomCapRect, const Radius.circular(4)),
      pipePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomCapRect, const Radius.circular(4)),
      edgePaint,
    );
  }
}
