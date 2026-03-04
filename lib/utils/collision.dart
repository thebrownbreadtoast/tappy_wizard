import 'dart:ui';

/// Simple AABB (axis-aligned bounding box) collision helpers.
class CollisionUtil {
  CollisionUtil._();

  /// Returns `true` when two rectangles overlap.
  static bool rectsOverlap(Rect a, Rect b) {
    return a.left < b.right &&
        a.right > b.left &&
        a.top < b.bottom &&
        a.bottom > b.top;
  }

  /// Returns `true` when [inner] is partially or fully outside [bounds].
  static bool isOutOfBounds(Rect inner, Rect bounds) {
    return inner.top < bounds.top ||
        inner.bottom > bounds.bottom ||
        inner.left < bounds.left ||
        inner.right > bounds.right;
  }
}
