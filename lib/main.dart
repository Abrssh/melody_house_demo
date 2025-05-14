import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:melody_house_demo/melody_house.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody House',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Create separate focus nodes
  final FocusNode _gameFocusNode = FocusNode();

  // Create a game instance that we can reference
  final MelodyHouseGame _game = MelodyHouseGame();

  @override
  void initState() {
    super.initState();
    // Request focus when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _gameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _gameFocusNode,
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          print('Main Key event: ${event.logicalKey.keyLabel}');
          // Forward the key event to the game
          _game.onKeyEvent(event, {event.logicalKey});
          return KeyEventResult.handled;
        },
        child: GameWidget(
          game: _game,
        ),
      ),
    );
  }
}
