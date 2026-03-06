import 'dart:ui' as ui;
import '../game/constants.dart';

/// A single pair of top + bottom pillar obstacles with a loop gap.
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

  ui.Rect get topRect =>
      ui.Rect.fromLTWH(x, 0, GameConstants.pipeWidth, _topHeight);

  ui.Rect get bottomRect => ui.Rect.fromLTWH(
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

  // ── Reused Render Objects ────────────────────────
  static final ui.Paint _pipePaint = ui.Paint()
    ..color = const ui.Color(0xFF2ECC71);
  static final ui.Paint _edgePaint = ui.Paint()
    ..color = const ui.Color(0xFF1B5E20)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 3;
  static final ui.Paint _highlightPaint = ui.Paint()
    ..color = const ui.Color(0x33FFFFFF);

  // ── Render ───────────────────────────────────────
  void render(ui.Canvas canvas) {
    // Draw Top Pipe
    canvas.drawRect(topRect, _pipePaint);
    canvas.drawRect(topRect, _edgePaint);
    canvas.drawRect(ui.Rect.fromLTWH(x + 5, 0, 8, _topHeight), _highlightPaint);

    // Top Pipe Cap
    final topCapRect = ui.Rect.fromLTWH(
      x - 4,
      _topHeight - 24,
      GameConstants.pipeWidth + 8,
      24,
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(topCapRect, const ui.Radius.circular(4)),
      _pipePaint,
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(topCapRect, const ui.Radius.circular(4)),
      _edgePaint,
    );

    // Draw Bottom Pipe
    canvas.drawRect(bottomRect, _pipePaint);
    canvas.drawRect(bottomRect, _edgePaint);
    canvas.drawRect(
      ui.Rect.fromLTWH(x + 5, _bottomTop, 8, screenHeight - _bottomTop),
      _highlightPaint,
    );

    // Bottom Pipe Cap
    final bottomCapRect = ui.Rect.fromLTWH(
      x - 4,
      _bottomTop,
      GameConstants.pipeWidth + 8,
      24,
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(bottomCapRect, const ui.Radius.circular(4)),
      _pipePaint,
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(bottomCapRect, const ui.Radius.circular(4)),
      _edgePaint,
    );
  }
}
