import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melody_house_demo/Components/collision_block.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';
import 'package:melody_house_demo/melody_house.dart';

class Player extends SpriteAnimationComponent
    with KeyboardHandler, HasGameReference<MelodyHouseGame> {
  // Movement properties
  final double _moveSpeed = 60.0;
  final Vector2 _velocity = Vector2.zero();
  bool _facingRight = true;

  // Collision properties
  final List<CollisionBlock> collisionBlocks;
  late final RectangleComponent _collisionHitbox;
  final bool _debugCollision = false; // Set to false in production

  // Footstep timer
  double _footstepTimer = 0.0;
  final double _footstepInterval = 0.3;
  String _currentSurface = 'grass';

  // Animations
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;

  Player({
    required Vector2 position,
    Vector2? size,
    required this.collisionBlocks,
  }) : super(
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

    final hitboxSize = Vector2(size.x * 0.15, size.y * 0.25);
    _collisionHitbox = RectangleComponent(
      size: hitboxSize,
      position: Vector2(
        (size.x - hitboxSize.x) / 2,
        (size.y - hitboxSize.y) / 2,
      ),
      paint: Paint()
        ..color =
            _debugCollision ? Colors.blue.withOpacity(0.3) : Colors.transparent
        ..style = PaintingStyle.fill,
    );

    // Add outline if debugging
    if (_debugCollision) {
      _collisionHitbox.paint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final outline = RectangleComponent(
        size: hitboxSize,
        position: Vector2.zero(),
        paint: Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _collisionHitbox.add(outline);
    }

    add(_collisionHitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply velocity to position with collision detection
    if (_velocity.x != 0 || _velocity.y != 0) {
      // Handle horizontal movement with collision
      final horizontalMovement = Vector2(_velocity.x * dt, 0);
      if (!_checkCollision(horizontalMovement)) {
        position.x += _velocity.x * dt;
      }

      // Handle vertical movement with collision
      final verticalMovement = Vector2(0, _velocity.y * dt);
      if (!_checkCollision(verticalMovement)) {
        position.y += _velocity.y * dt;
      }

      // Switch to run animation when moving
      if (animation != _runAnimation) {
        animation = _runAnimation;
      }

      // Play footstep sounds when moving
      _footstepTimer += dt;
      if (_footstepTimer >= _footstepInterval) {
        _footstepTimer = 0;
        game.audioManager.playFootstep(_currentSurface);
      }
    } else {
      // Switch to idle animation when not moving
      if (animation != _idleAnimation) {
        animation = _idleAnimation;
      }

      // Reset footstep timer when not moving
      _footstepTimer = 0;
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

  bool _checkCollision(Vector2 movement) {
    // Calculate the player's hitbox in world coordinates
    final hitboxPosition =
        position + _collisionHitbox.position + movement - (size / 2);
    final playerRect = Rect.fromLTWH(
      hitboxPosition.x,
      hitboxPosition.y,
      _collisionHitbox.size.x,
      _collisionHitbox.size.y,
    );

    // Check collision with each collision block
    for (final block in collisionBlocks) {
      final blockRect = Rect.fromLTWH(
        block.position.x,
        block.position.y,
        block.size.x,
        block.size.y,
      );

      if (playerRect.overlaps(blockRect)) {
        return true; // Collision detected
      }
    }

    return false; // No collision
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

    // Mute/UnMute
    if (event is KeyDownEvent &&
        keysPressed.contains(LogicalKeyboardKey.keyM)) {
      game.audioManager.toggleMute();
      return true;
    }

    // Normalize diagonal movement to prevent faster diagonal speed
    if (_velocity.length > _moveSpeed) {
      _velocity.normalize();
      _velocity.scale(_moveSpeed);
    }

    return super.onKeyEvent(event, keysPressed);
  }

  // Method to set the current surface type (call this when player moves to different terrain)
  void setCurrentSurface(String surface) {
    _currentSurface = surface;
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
