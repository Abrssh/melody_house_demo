import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:async';

import 'package:melody_house_demo/engine_and_audio/melody_house.dart';

class GameScreen extends StatefulWidget {
  final bool startIndoors;

  const GameScreen({super.key, required this.startIndoors});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MelodyHouseGame _game;
  bool _showTutorial = true;
  late Timer _tutorialTimer;

  @override
  void initState() {
    super.initState();
    _game = MelodyHouseGame();

    // Start the timer to hide the tutorial after 10 seconds
    _tutorialTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showTutorial = false;
        });
      }
    });

    // Load the appropriate scene after the game is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startIndoors) {
        _game.loadIndoorScene();
      } else {
        _game.loadOutdoorScene();
      }
    });
  }

  @override
  void dispose() {
    _tutorialTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          if (_showTutorial) _buildMovementTutorial(),
          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildMovementTutorial() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.black54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Movement Controls',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKeyInstruction('W', 'Move Up'),
              const SizedBox(width: 20),
              _buildKeyInstruction('A', 'Move Left'),
              const SizedBox(width: 20),
              _buildKeyInstruction('S', 'Move Down'),
              const SizedBox(width: 20),
              _buildKeyInstruction('D', 'Move Right'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKeyInstruction('E', 'Interact'),
              const SizedBox(width: 20),
              _buildKeyInstruction('M', 'Mute/Unmute'),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'This tutorial will disappear in a few seconds...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInstruction(String key, String action) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          action,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return Positioned(
      top: 20,
      right: 20,
      child: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
        onPressed: () {
          _showPauseMenu();
        },
      ),
    );
  }

  void _showPauseMenu() {
    _game.pauseEngine();
    _game.audioManager.pauseMusic();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double musicVolume = _game.audioManager.getMusicVolume();
          double sfxVolume = _game.audioManager.getSfxVolume();

          return AlertDialog(
            title: const Text('Game Paused'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.music_note),
                    const SizedBox(width: 10),
                    const Text('Music Volume'),
                    Expanded(
                      child: Slider(
                        value: musicVolume,
                        onChanged: (value) {
                          setState(() {
                            musicVolume = value;
                            _game.audioManager.setMusicVolume(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.volume_up),
                    const SizedBox(width: 10),
                    const Text('SFX Volume'),
                    Expanded(
                      child: Slider(
                        value: sfxVolume,
                        onChanged: (value) {
                          setState(() {
                            sfxVolume = value;
                            _game.audioManager.setSfxVolume(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _game.resumeEngine();
                  _game.audioManager.resumeMusic();
                },
                child: const Text('Resume'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to main menu
                },
                child: const Text('Exit to Menu'),
              ),
            ],
          );
        },
      ),
    );
  }
}
