import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// class SpecialZoneIndicator extends PositionComponent {
//   final Paint _paint;
//   double _animationTime = 0;
//   final double radius;
//   final double pulseSpeed;
//   final double maxOpacity;

//   SpecialZoneIndicator({
//     required Vector2 position,
//     required Vector2 size,
//     this.radius = 40.0,
//     this.pulseSpeed = 3.0,
//     this.maxOpacity = 0.7,
//     Color color = const Color(0xFFFFD700),
//   })  : _paint = Paint()
//           ..color = color.withOpacity(0)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 4.0,
//         super(
//           position: position,
//           size: size,
//         ) {
//     debugPrint("Special Zone Position: $position Size: $size");
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, _paint);
//     canvas.drawCircle(Offset.zero, radius + 20, _paint);
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.x + 20, size.y + 15),
//       Paint()..color = Colors.amber.withOpacity(0.5),
//     );
//   }

//   @override
//   void update(double dt) {
//     _animationTime += dt * pulseSpeed;

//     // Create a pulsing effect
//     final opacity = (math.sin(_animationTime) * 0.5 + 0.5) * maxOpacity;
//     _paint.color = _paint.color.withOpacity(opacity);

//     super.update(dt);
//   }
// }

class SpecialZoneIndicator2 extends PositionComponent {
  final Paint _paint;
  double _animationTime = 0;
  final double radius;
  final double pulseSpeed;
  final double maxOpacity;

  SpecialZoneIndicator2({
    required Vector2 position,
    required Vector2 size,
    this.radius = 20.0,
    this.pulseSpeed = 3.0,
    this.maxOpacity = 0.4,
    Color color = const Color(0xFFFFD700),
  })  : _paint = Paint()
          ..color = color.withOpacity(0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
        super(
          position: position,
          size: size,
        );

  @override
  void render(Canvas canvas) {
    // Uncomment for debugging collisions
    canvas.drawCircle(Offset.zero, radius, _paint);
    // Interesting shape
    // canvas.drawCircle(Offset(size.x - 2, size.y - 4), radius, _paint);
    // canvas.drawCircle(Offset(size.x - 4, size.y - 4), radius, _paint);
  }

  @override
  void update(double dt) {
    _animationTime += dt * pulseSpeed;

    // Create a pulsing effect
    final opacity = (math.sin(_animationTime) * 0.5 + 0.5) * maxOpacity;
    _paint.color = _paint.color.withOpacity(opacity);

    super.update(dt);
  }
}
