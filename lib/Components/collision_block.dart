import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CollisionBlock extends PositionComponent {
  CollisionBlock({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  void render(Canvas canvas) {
    // Uncomment for debugging collisions
    // canvas.drawRect(
    //   Rect.fromLTWH(0, 0, size.x, size.y),
    //   Paint()..color = Colors.red.withOpacity(0.5),
    // );
  }
}
