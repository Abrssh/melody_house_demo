import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SceneTransition extends Component with HasGameReference {
  final VoidCallback onComplete;
  final double duration;

  // 0 = fully transparent, 1 = fully opaque black
  double _opacity = 0.0;
  bool _isFadingIn = false;
  bool _isFadingOut = true;

  SceneTransition({
    required this.onComplete,
    this.duration = 2.0,
  });

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
        0, 0, game.camera.viewport.size.x, game.camera.viewport.size.y);

    canvas.drawRect(
      rect,
      Paint()..color = Colors.black.withOpacity(_opacity),
    );

    // Draw loading text when mostly opaque
    if (_opacity > 0.7) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: 'Loading...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (rect.width - textPainter.width) / 2,
          (rect.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    if (_isFadingOut) {
      _opacity += dt / (duration / 2);
      if (_opacity >= 1.0) {
        _opacity = 1.0;
        _isFadingOut = false;
        onComplete();
        _isFadingIn = true;
      }
    } else if (_isFadingIn) {
      _opacity -= dt / (duration / 2);
      if (_opacity <= 0.0) {
        _opacity = 0.0;
        _isFadingIn = false;
        removeFromParent();
      }
    }
  }
}
