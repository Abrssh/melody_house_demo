import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:melody_house_demo/components/camera_controller.dart';
import 'package:melody_house_demo/components/collision_block.dart';
import 'package:melody_house_demo/components/objects/player_component.dart';
import 'package:melody_house_demo/components/objects/sheep_component.dart';
import 'package:melody_house_demo/components/ui/special_zone_indicator.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';
import 'package:melody_house_demo/engine_and_audio/melody_house.dart';

class IndoorScene extends Component with HasGameReference<MelodyHouseGame> {
  late final World world;
  late final CameraComponent cameraComponent;
  late final TiledComponent tiledMap;
  late final Player player;

  final List<CollisionBlock> _collisionBlocks = [];

  double mapWidth = 0;
  double mapHeight = 0;

  late final Vector2 outDoorGatewayPosition;

  late final Vector2 sheepPosition;
  late final SheepComponent sheep;

  late AudioPlayer _audioPlayer;

  @override
  Future<void> onLoad() async {
    // Create a world for this scene
    world = World();
    add(world);

    try {
      // Load the tiled map
      tiledMap = await TiledComponent.load(
        AssetPath.indoorTileMap,
        Vector2.all(16),
        prefix: "assets/tiles/",
      );

      world.add(tiledMap);
      debugPrint('Tiled map loaded successfully');

      // Calculate map dimensions
      mapWidth = tiledMap.tileMap.map.width *
          tiledMap.tileMap.map.tileWidth.toDouble();
      mapHeight = tiledMap.tileMap.map.height *
          tiledMap.tileMap.map.tileHeight.toDouble();

      debugPrint('Map dimensions: $mapWidth x $mapHeight');

      // Load collision objects from the object layer
      // Assuming your object layer is named "Collisions"
      final collisionsLayer =
          tiledMap.tileMap.getLayer<ObjectGroup>('Collisions');

      if (collisionsLayer != null) {
        for (final obj in collisionsLayer.objects) {
          if (obj.name == 'Interaction 1') {
            sheepPosition = Vector2(obj.x + 10, obj.y);

            // Add the sheep
            sheep = SheepComponent(
              position: sheepPosition,
              size: Vector2(24, 24),
            );
            world.add(sheep);

            // Add interaction zone indicator
            final sheepInteractionZone = SpecialZoneIndicator2(
              position: sheepPosition,
              size: Vector2(24, 24),
              color: Colors.white,
              radius: 15,
              pulseSpeed: 4,
            );
            world.add(sheepInteractionZone);

            debugPrint('Sheep added at position: $sheepPosition');
          }
          final collisionBlock = CollisionBlock(
            position: Vector2(obj.x, obj.y),
            size: Vector2(obj.width, obj.height),
          );
          _collisionBlocks.add(collisionBlock);
          world.add(collisionBlock);
        }
        debugPrint('Loaded ${_collisionBlocks.length} collision blocks');
      } else {
        debugPrint(
            'No collision layer found. Make sure you have a layer named "Collisions"');
      }

      // Load spawn point objects from the object layer
      final spawnPointsLayer =
          tiledMap.tileMap.getLayer<ObjectGroup>('SpawnPoints');
      Vector2 spawnPoint = Vector2.zero();

      if (spawnPointsLayer != null) {
        for (final obj in spawnPointsLayer.objects) {
          // Assuming there's only one spawn point object
          if (obj.name == 'player') {
            spawnPoint = Vector2(obj.x, obj.y);
            debugPrint('Player spawn point set to: ${obj.position}');
          } else if (obj.name == 'outdoor') {
            outDoorGatewayPosition = Vector2(obj.x, obj.y);
            // Add a visual indicator at the gateway position
            final gatewayPositionIndicator = SpecialZoneIndicator2(
              position: Vector2(obj.x, obj.y),
              size: Vector2(obj.width, obj.height),
            );
            world.add(gatewayPositionIndicator);
            debugPrint('Outdoor gateway spawn point set to: ${obj.position}');
          }
        }
      } else {
        debugPrint(
            'No spawn point layer found. Make sure you have a layer named "SpawnPoints"');
      }

      // Create player at the center of the map
      player = Player(
        position: Vector2(spawnPoint.x, spawnPoint.y),
        size: Vector2(64, 64),
        collisionBlocks: _collisionBlocks,
        gateWayPosition: outDoorGatewayPosition,
        onGateWayReached: exitBuilding,
        currentSurface: 'gravel',
        sheepPosition: sheepPosition,
        onSheepReached: handleInteraction,
      );
      world.add(player);

      // Setup camera
      cameraComponent = CameraComponent(world: world);
      cameraComponent.viewfinder.anchor = Anchor.center;
      cameraComponent.viewfinder.position =
          Vector2(mapWidth / 2, mapHeight / 2);
      cameraComponent.viewfinder.zoom = 4.0;
      add(cameraComponent);

      add(CameraController(
        player: player,
        mapWidth: mapWidth.toDouble(),
        mapHeight: mapHeight.toDouble(),
        camera: cameraComponent,
      ));

      // Play background audio
      game.audioManager.playBackgroundMusic(AssetPath.indoorMusic);
      game.audioManager.setMusicVolume(0.5);
    } catch (e) {
      debugPrint('Failed to load Tiled map: $e');
      world.add(RectangleComponent(
        size: Vector2(300, 300),
        position: Vector2(200, 150),
        paint: BasicPalette.red.paint(),
      ));
    }

    return super.onLoad();
  }

  // Method to switch to outdoor scene
  void exitBuilding() {
    game.loadOutdoorScene();
  }

  void handleInteraction(String type) async {
    if (type == 'start') {
      debugPrint("Sheep interaction started");
      // Play regular interaction sound
      game.audioManager.playInteractionSound('interaction_object');
      // Play sheep interaction sound
      _audioPlayer =
          await game.audioManager.playInteractionSound('sheep_interaction');

      game.audioManager.pauseMusic();

      // Start sheep animation
      sheep.startInteraction();

      // After 3 seconds, restore music volume and stop animation
      // Future.delayed(const Duration(seconds: 59), () {
      //   game.audioManager.resumeMusic();
      //   sheep.stopInteraction();
      // });
    } else if (type == 'end') {
      debugPrint("Sheep interaction ended");
      // Stop sheep animation
      sheep.stopInteraction();
      _audioPlayer.stop();
      game.audioManager.resumeMusic();
    }
  }
}
