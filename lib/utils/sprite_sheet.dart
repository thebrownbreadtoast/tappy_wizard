import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Loads a sprite-sheet image and slices it into equal-width frames.
///
/// Frames are laid out **horizontally** in a single row.
class SpriteSheet {
  final ui.Image image;
  final int frameCount;
  late final double frameWidth;
  late final double frameHeight;

  SpriteSheet({required this.image, required this.frameCount}) {
    frameWidth = image.width / frameCount;
    frameHeight = image.height.toDouble();
  }

  /// Returns the source [Rect] for the frame at [index].
  ui.Rect frameRect(int index) {
    assert(index >= 0 && index < frameCount);
    return ui.Rect.fromLTWH(index * frameWidth, 0, frameWidth, frameHeight);
  }

  /// Loads an image from the asset bundle and builds a [SpriteSheet].
  static Future<SpriteSheet> load(String assetPath, int frameCount) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return SpriteSheet(image: frame.image, frameCount: frameCount);
  }
}

/// Manages frame-based animation timing.
class SpriteAnimator {
  final int frameCount;
  final double frameDuration; // seconds per frame

  double _elapsed = 0;
  int _currentFrame = 0;

  SpriteAnimator({required this.frameCount, required this.frameDuration});

  int get currentFrame => _currentFrame;

  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= frameDuration) {
      _elapsed -= frameDuration;
      _currentFrame = (_currentFrame + 1) % frameCount;
    }
  }

  void reset() {
    _elapsed = 0;
    _currentFrame = 0;
  }
}
