import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps tap + keyboard input into a single callback.
///
/// Use as a parent widget around the game canvas.
class InputService extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final FocusNode _focusNode = FocusNode();

  InputService({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          onTap();
        }
      },
      child: GestureDetector(
        onTapDown: (_) => onTap(),
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
