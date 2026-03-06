import 'dart:ui' as ui;

enum PowerUpType { extraLife, magicSpell }

class PowerUp {
  double x;
  double y;
  final PowerUpType type;
  final double size = 32.0;
  bool collected = false;

  PowerUp({required this.x, required this.y, required this.type});

  ui.Rect get rect => ui.Rect.fromLTWH(x, y, size, size);

  void update(double dt, double speed) {
    x -= speed * dt;
  }

  bool get isOffScreen => x + size < 0;

  // ── Reused Render Objects ────────────────────────
  final ui.Paint _imagePaint = ui.Paint();
  final ui.Paint _lifePaint = ui.Paint()..color = const ui.Color(0xFFFF0000);
  final ui.Paint _spellPaint = ui.Paint()..color = const ui.Color(0xFF0000FF);

  void render(ui.Canvas canvas, ui.Image? image) {
    if (image != null) {
      final src = ui.Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      canvas.drawImageRect(image, src, rect, _imagePaint);
    } else {
      // Fallback
      canvas.drawRect(
        rect,
        type == PowerUpType.extraLife ? _lifePaint : _spellPaint,
      );
    }
  }
}
