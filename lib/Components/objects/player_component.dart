import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melody_house_demo/components/collision_block.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';
import 'package:melody_house_demo/engine_and_audio/melody_house.dart';

enum InteractionType { gateway, sheep }

class Player extends SpriteAnimationComponent
    with KeyboardHandler, HasGameReference<MelodyHouseGame> {
  // Movement properties
  final double _moveSpeed = 60.0;
  final Vector2 _velocity = Vector2.zero();
  bool _facingRight = true;

  // Collision properties
  final List<CollisionBlock> collisionBlocks;
  late final RectangleComponent _collisionHitbox;
  final bool _debugCollision = false; // Set to true in debugging

  // Footstep timer
  double _footstepTimer = 0.0;
  final double _footstepInterval = 0.3;
  String currentSurface = 'grass';

  // Gateway interaction
  final Vector2 gateWayPosition;
  final VoidCallback onGateWayReached;
  final double _interactionDistance = 25.0; // Reduced distance to show prompt
  bool _isNearGateway = false;
  late final TextComponent _interactionPrompt;
  bool _transitionInProgress = false; // Flag to prevent multiple transitions

  // Sheep Interaction
  final Vector2? sheepPosition;
  final Function(String type)? onSheepReached;
  final double _sheepInteractionDistance =
      25.0; // Reduced distance to show prompt
  bool _isNearSheep = false;
  bool _sheepInteractionProgress = false;

  // Animations
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;

  bool _textFlipped = false;

  Player({
    required Vector2 position,
    required this.gateWayPosition,
    required this.onGateWayReached,
    this.currentSurface = "grass",
    Vector2? size,
    required this.collisionBlocks,
    this.sheepPosition,
    this.onSheepReached,
  }) : super(
            position: position,
            size: size ?? Vector2(32, 48),
            anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugPrint('Player loaded');

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

    // Create interaction prompt
    _interactionPrompt = TextComponent(
      text: 'Press E',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(20, -40), // Position above the player
    );

    // Debug gateway position
    if (_debugCollision) {
      final gatewayMarker = CircleComponent(
        radius: 5,
        position: Vector2(gateWayPosition.x, gateWayPosition.y),
        paint: Paint()..color = Colors.red,
      );
      game.world.add(gatewayMarker);
      debugPrint('Gateway position: $gateWayPosition');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Skip updates if transition is in progress
    if (_transitionInProgress) return;

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
        game.audioManager.playFootstep(currentSurface);
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
      if (_textFlipped) {
        _textFlipped = false;
        _interactionPrompt.flipHorizontallyAroundCenter();
      }
    } else if (_velocity.x < 0 && _facingRight) {
      _facingRight = false;
      flipHorizontallyAroundCenter();
      _textFlipped = true;
      if (_textFlipped) {
        _interactionPrompt.flipHorizontallyAroundCenter();
      }
    }

    // Check distance to gateway
    _isNearGateway = handlePlayerInteraction(_isNearGateway, gateWayPosition,
        _interactionDistance, InteractionType.gateway);

    // Check distance to sheep
    if (sheepPosition != null) {
      _isNearSheep = handlePlayerInteraction(_isNearSheep, sheepPosition!,
          _sheepInteractionDistance, InteractionType.sheep);
    }
  }

  bool handlePlayerInteraction(bool nearZone, Vector2 gateWayPosition,
      double interactionDistance, InteractionType interactionType) {
    final distanceToGateway = position.distanceTo(gateWayPosition);
    final wasNearGateway = nearZone;
    nearZone = distanceToGateway <= interactionDistance;

    // More efficient approach: Add/remove the prompt component instead of toggling visibility
    if (nearZone && !wasNearGateway) {
      // Only add if not already a child
      if (!children.contains(_interactionPrompt)) {
        add(_interactionPrompt);
      }
    } else if (!nearZone && wasNearGateway) {
      // Only remove if it's a child
      if (children.contains(_interactionPrompt)) {
        remove(_interactionPrompt);
      }
      if (interactionType == InteractionType.sheep &&
          _sheepInteractionProgress) {
        _sheepInteractionProgress = false;
        onSheepReached!("end");
      }
    }
    return nearZone;
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

    // Don't check gateway collision - allow player to move freely through gateway
    return false; // No collision
  }

  // Track pressed keys for collision check
  Set<LogicalKeyboardKey> keysPressed = {};

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    this.keysPressed = keysPressed;

    // Skip key handling if transition is in progress
    if (_transitionInProgress) return true;

    // Reset velocity
    _velocity.setZero();

    // Check which keys are pressed and update velocity accordingly
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _velocity.y = -_moveSpeed;
      debugPrint("W pressed ${_velocity.y}");
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

    // Gateway interaction - only trigger on key down, not while key is held
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyE &&
        (_isNearGateway || _isNearSheep)) {
      if (_isNearGateway) {
        _transitionInProgress = true; // Prevent multiple transitions

        // play interaction sound
        game.audioManager.playInteractionSound('interaction_object');

        // Use Future.delayed to ensure the transition happens after the current frame
        Future.delayed(Duration.zero, () {
          onGateWayReached();
        });
      } else if (_isNearSheep && !_sheepInteractionProgress) {
        _sheepInteractionProgress =
            true; // Using the same flag for sheep interaction
        if (onSheepReached != null) {
          onSheepReached!("start");
        }
      }
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
    currentSurface = surface;
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
