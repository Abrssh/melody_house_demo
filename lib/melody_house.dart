import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melody_house_demo/Components/audio_manager.dart';
import 'package:melody_house_demo/Components/outdoor_scene.dart';

class MelodyHouseGame extends FlameGame with KeyboardEvents {
  Component? _currentScene;
  final AudioManager audioManager = AudioManager();

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
    await loadOutdoorScene();
    return super.onLoad();
  }

  Future<void> loadOutdoorScene() async {
    // Remove current scene if it exists
    if (_currentScene != null) {
      remove(_currentScene!);
      _currentScene = null;
    }

    // Create and add the outdoor scene
    _currentScene = OutdoorScene();
    await add(_currentScene!);
  }

  Future<void> loadIndoorScene() async {
    // Remove current scene if it exists
    if (_currentScene != null) {
      remove(_currentScene!);
      _currentScene = null;
    }

    // Create and add the indoor scene (when you implement it)
    // _currentScene = IndoorScene();
    // await add(_currentScene!);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_currentScene is OutdoorScene) {
      final outdoorScene = _currentScene as OutdoorScene;

      outdoorScene.player.onKeyEvent(event, keysPressed);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
