import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melody_house_demo/Components/audio_manager.dart';
import 'package:melody_house_demo/Components/indoor_scene.dart';
import 'package:melody_house_demo/Components/outdoor_scene.dart';
import 'package:melody_house_demo/Components/scene_transition.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';

class MelodyHouseGame extends FlameGame with KeyboardEvents {
  Component? _currentScene;
  final AudioManager audioManager = AudioManager();
  bool _isTransitioning = false;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'characters/human/idle/base_idle_strip9.png',
      'characters/human/run/base_run_strip8.png',
      'characters/human/idle/curlyhair_idle_strip9.png',
      'characters/human/run/curlyhair_run_strip8.png',
    ]);

    await audioManager.initialize();

    // Load the outdoor scene
    // await loadOutdoorScene();
    await loadIndoorScene();
    return super.onLoad();
  }

  Future<void> loadOutdoorScene() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    // Add a transition component that handles both fade out and fade in
    add(SceneTransition(
      duration: 1.5,
      onComplete: () async {
        // This is called when fade out is complete

        // Remove current scene if it exists
        if (_currentScene != null) {
          remove(_currentScene!);
        }

        // Create and add the new scene
        _currentScene = OutdoorScene();
        await add(_currentScene!);

        // Play background audio
        audioManager.playBackgroundMusic(AssetPath.outdoorMusic);
        audioManager.setMusicVolume(0.5);

        // When fade in completes, the transition component will remove itself
        _isTransitioning = false;
      },
    ));
  }

  Future<void> loadIndoorScene() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    // Add a transition component that handles both fade out and fade in
    add(SceneTransition(
      duration: 1.5,
      onComplete: () async {
        // This is called when fade out is complete

        // Remove current scene
        if (_currentScene != null) {
          remove(_currentScene!);
        }

        // Create and add the new scene
        _currentScene = IndoorScene();
        await add(_currentScene!);

        // Play background audio
        audioManager.playBackgroundMusic(AssetPath.indoorMusic);
        audioManager.setMusicVolume(0.5);

        // When fade in completes, the transition component will remove itself
        _isTransitioning = false;
      },
    ));
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_isTransitioning) return KeyEventResult.handled;

    if (_currentScene is OutdoorScene) {
      final outdoorScene = _currentScene as OutdoorScene;
      outdoorScene.player.onKeyEvent(event, keysPressed);
      return KeyEventResult.handled;
    } else if (_currentScene is IndoorScene) {
      final indoorScene = _currentScene as IndoorScene;
      indoorScene.player.onKeyEvent(event, keysPressed);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
