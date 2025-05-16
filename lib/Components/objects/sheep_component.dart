import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';
import 'package:melody_house_demo/engine_and_audio/melody_house.dart';

class SheepComponent extends SpriteAnimationComponent
    with HasGameReference<MelodyHouseGame> {
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _activeAnimation;
  bool _isInteracting = false;

  SheepComponent({
    required Vector2 position,
    Vector2? size,
  }) : super(
          position: position,
          size: size ?? Vector2(48, 48),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create the idle animation with extremely slow frame rate (essentially static)
    _idleAnimation = _spriteAnimationCreation(AssetPath.sheepSprite, 4,
        100.0 // Very slow frame rate - effectively paused on first frame
        );

    // Create the active animation with normal frame rate
    _activeAnimation = _spriteAnimationCreation(
        AssetPath.sheepSprite, 4, 0.1 // Normal animation speed
        );

    // Set initial animation to the slow one
    animation = _idleAnimation;

    debugPrint('Sheep loaded at position: $position');
  }

  // Start animation when interacted with
  void startInteraction() {
    if (!_isInteracting) {
      _isInteracting = true;
      animation = _activeAnimation;
    }
  }

  // Stop animation and return to "static" state
  void stopInteraction() {
    if (_isInteracting) {
      _isInteracting = false;
      animation = _idleAnimation;
    }
  }

  SpriteAnimation _spriteAnimationCreation(
      String fileName, int numberOfSprites, double stepTime) {
    final image = game.images.fromCache(fileName);
    final imageFrameWidth = image.width / numberOfSprites;
    return SpriteAnimation.fromFrameData(
        game.images.fromCache(fileName),
        SpriteAnimationData.sequenced(
            amount: numberOfSprites,
            stepTime: stepTime,
            amountPerRow: numberOfSprites,
            textureSize: Vector2(imageFrameWidth, image.height.toDouble())));
  }
}
