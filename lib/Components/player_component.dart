import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';

class Player extends SpriteAnimationComponent
    with KeyboardHandler, HasGameReference {
  // Movement properties
  final double _moveSpeed = 60.0;
  final Vector2 _velocity = Vector2.zero();
  bool _facingRight = true;

  // Animations
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;

  Player({required Vector2 position, Vector2? size})
      : super(
            position: position,
            size: size ?? Vector2(32, 48),
            anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create idle animation with calculated dimensions
    _idleAnimation =
        _spriteAnimationCreation(AssetPath.playerIdleSprite, 9, 0.08);

    // Create run animation with calculated dimensions
    _runAnimation =
        _spriteAnimationCreation(AssetPath.playerRunSprite, 8, 0.08);

    // Set initial animation
    animation = _idleAnimation;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply velocity to position
    if (_velocity.x != 0 || _velocity.y != 0) {
      position += _velocity * dt;

      // Switch to run animation when moving
      if (animation != _runAnimation) {
        animation = _runAnimation;
      }
    } else {
      // Switch to idle animation when not moving
      if (animation != _idleAnimation) {
        animation = _idleAnimation;
      }
    }

    // Update sprite direction based on horizontal movement
    if (_velocity.x > 0 && !_facingRight) {
      _facingRight = true;
      flipHorizontallyAroundCenter();
    } else if (_velocity.x < 0 && _facingRight) {
      _facingRight = false;
      flipHorizontallyAroundCenter();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    debugPrint("Event:  Keys: $keysPressed");
    // Reset velocity
    _velocity.setZero();

    // Check which keys are pressed and update velocity accordingly
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _velocity.y = -_moveSpeed;
      debugPrint("W pressed");
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _velocity.y = _moveSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _velocity.x = -_moveSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _velocity.x = _moveSpeed;
    }

    // Normalize diagonal movement to prevent faster diagonal speed
    if (_velocity.length > _moveSpeed) {
      _velocity.normalize();
      _velocity.scale(_moveSpeed);
    }

    return super.onKeyEvent(event, keysPressed);
  }

  SpriteAnimation _spriteAnimationCreation(
      String fileName, int numberOfSprites, stepTime) {
    final image = game.images.fromCache(fileName);
    // Calculate frame width for each animation
    final imageFrameWidth = image.width / numberOfSprites;
    debugPrint(
        "Image Frame Width: $imageFrameWidth Image height ${image.height}");
    return SpriteAnimation.fromFrameData(
        game.images.fromCache(fileName),
        SpriteAnimationData.sequenced(
            amount: numberOfSprites,
            stepTime: stepTime,
            amountPerRow: numberOfSprites,
            textureSize: Vector2(imageFrameWidth, image.height.toDouble())));
  }
}
