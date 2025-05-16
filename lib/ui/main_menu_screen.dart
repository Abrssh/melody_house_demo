import 'package:flutter/material.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';
import 'package:melody_house_demo/engine_and_audio/audio_manager.dart';
import 'package:melody_house_demo/ui/game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final AudioManager _audioManager = AudioManager();
  bool _isIndoorSelected = false;
  bool _isOutdoorSelected = false;
  double _sfxVolume = 1.0;
  double _musicVolume = 0.7;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioManager.initialize();
    // Play menu background music
    await _audioManager.playBackgroundMusic(AssetPath.menuMusic);
    _audioManager.setMusicVolume(_musicVolume);
    setState(() {
      _sfxVolume = _audioManager.getSfxVolume();
      _musicVolume = _audioManager.getMusicVolume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, Colors.purple[900]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Melody House',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                'Select a Scene',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSceneOption(
                    'Indoor',
                    _isIndoorSelected,
                    () {
                      _audioManager.playInteractionSound('selection');
                      setState(() {
                        _isIndoorSelected = true;
                        _isOutdoorSelected = false;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildSceneOption(
                    'Outdoor',
                    _isOutdoorSelected,
                    () {
                      _audioManager.playInteractionSound('selection');
                      setState(() {
                        _isOutdoorSelected = true;
                        _isIndoorSelected = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildVolumeControls(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: (_isIndoorSelected || _isOutdoorSelected)
                    ? () {
                        _audioManager.playInteractionSound('confirm');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              startIndoors: _isIndoorSelected,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Play Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSceneOption(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.7) : Colors.black54,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.white30,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_note, color: Colors.white),
              const SizedBox(width: 10),
              const Text(
                'Music Volume',
                style: TextStyle(color: Colors.white),
              ),
              Slider(
                value: _musicVolume,
                onChanged: (value) {
                  setState(() {
                    _musicVolume = value;
                    _audioManager.setMusicVolume(value);
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up, color: Colors.white),
              const SizedBox(width: 10),
              const Text(
                'SFX Volume',
                style: TextStyle(color: Colors.white),
              ),
              Slider(
                value: _sfxVolume,
                onChanged: (value) {
                  setState(() {
                    _sfxVolume = value;
                    _audioManager.setSfxVolume(value);
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
