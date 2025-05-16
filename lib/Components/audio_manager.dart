import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // static final AudioManager instance = AudioManager._internal();

  // Background music player
  late AudioPlayer _bgmPlayer;
  // To control interaction sounds

  // Footstep sound players (for different surfaces)
  final Map<String, String> _footstepSounds = {
    'grass': AssetPath.grassRunningSound,
    'water': AssetPath.waterRunningSound,
    'gravel': AssetPath.gravelRunningSound,
  };

  // Interaction sounds
  final Map<String, String> _interactionSounds = {
    "house_enter": AssetPath.houseEnterSound,
    "interaction_object": AssetPath.interactionObjectSound,
    "sheep_interaction": AssetPath.sheepInteractionSound,
  };

  // Transition sounds
  final Map<String, String> _transitionSounds = {
    'house_enter': AssetPath.houseEnterSound,
  };

  bool _isMuted = false;
  double _masterVolume = 1.0;
  double _musicVolume = 0.7;
  double _sfxVolume = 1.0;

  Future<void> initialize() async {
    // Preload all audio files
    await _preloadAudio();

    // Initialize background music player
    _bgmPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop); // Loop background music
  }

  Future<void> _preloadAudio() async {
    // Preload footstep sounds
    for (final surfaceSound in _footstepSounds.values) {
      await FlameAudio.audioCache.load(surfaceSound);
    }

    // Preload interaction sounds
    for (final sound in _interactionSounds.values) {
      await FlameAudio.audioCache.load(sound);
    }

    // Preload transition sounds
    for (final sound in _transitionSounds.values) {
      await FlameAudio.audioCache.load(sound);
    }
  }

  // Play background music
  Future<void> playBackgroundMusic(String filename) async {
    if (_isMuted) return;

    await _bgmPlayer.stop();
    await _bgmPlayer.setVolume(_musicVolume * _masterVolume);
    await _bgmPlayer.play(AssetSource(filename));
  }

  // Play footstep sound based on surface
  void playFootstep(String surface) {
    try {
      if (_isMuted) return;

      if (!_footstepSounds.containsKey(surface)) {
        surface = 'grass'; // Default surface
      }

      final sounds = _footstepSounds[surface]!;
      // final randomIndex = DateTime.now().millisecondsSinceEpoch % sounds.length;
      FlameAudio.play(sounds, volume: _sfxVolume * _masterVolume);
    } catch (e) {
      debugPrint("Error playing footstep sound: $e");
    }
  }

  // Play interaction sound
  Future<AudioPlayer> playInteractionSound(String interaction) async {
    if (_isMuted) return AudioPlayer();

    if (_interactionSounds.containsKey(interaction)) {
      return await FlameAudio.play(_interactionSounds[interaction]!,
          volume: _sfxVolume * _masterVolume);
    }
    return Future.value(AudioPlayer());
  }

  // Play transition sound
  void playTransitionSound(String transition) {
    if (_isMuted) return;

    if (_transitionSounds.containsKey(transition)) {
      FlameAudio.play(_transitionSounds[transition]!,
          volume: _sfxVolume * _masterVolume);
    }
  }

  // Volume controls
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_musicVolume * _masterVolume);
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_musicVolume * _masterVolume);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint("Muted: $_isMuted");
    if (_isMuted) {
      _bgmPlayer.setVolume(0);
    } else {
      _bgmPlayer.setVolume(_musicVolume * _masterVolume);
    }
  }

  double getMusicVolume() {
    return _musicVolume;
  }

  void pauseMusic() {
    _bgmPlayer.pause();
  }

  void resumeMusic() {
    _bgmPlayer.resume();
  }

  void dispose() {
    _bgmPlayer.dispose();
  }
}
