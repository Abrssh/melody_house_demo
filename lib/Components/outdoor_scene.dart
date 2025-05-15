import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:melody_house_demo/Components/camera_controller.dart';
import 'package:melody_house_demo/Components/collision_block.dart';
import 'package:melody_house_demo/Components/player_component.dart';
import 'package:melody_house_demo/Constants/asset_path.dart';
import 'package:melody_house_demo/melody_house.dart';

class OutdoorScene extends Component with HasGameReference<MelodyHouseGame> {
  late final World world;
  late final CameraComponent cameraComponent;
  late final TiledComponent tiledMap;
  late final Player player;

  final List<CollisionBlock> _collisionBlocks = [];

  double mapWidth = 0;
  double mapHeight = 0;

  @override
  Future<void> onLoad() async {
    // Create a world for this scene
    world = World();
    add(world);

    try {
      // Load the tiled map
      tiledMap = await TiledComponent.load(
        AssetPath.outdoorTileMap,
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

      // Create player at the center of the map
      player = Player(
        position: Vector2(mapWidth / 2, mapHeight / 2),
        size: Vector2(64, 64),
        collisionBlocks: _collisionBlocks,
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
      game.audioManager.playBackgroundMusic(AssetPath.outdoorMusic);
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

  // Works but better if the camera bound system is its own component
  // @override
  // void update(double dt) {
  //   super.update(dt);

  //   // CRITICAL: This is where we manually update the camera position
  //   // Debug the current positions
  //   debugPrint('Player position: ${player.position}');
  //   debugPrint(
  //       'Camera position before update: ${cameraComponent.viewfinder.position}');

  //   // Calculate visible area
  //   final visibleWidth = game.size.x / cameraComponent.viewfinder.zoom;
  //   final visibleHeight = game.size.y / cameraComponent.viewfinder.zoom;

  //   final halfVisibleWidth = visibleWidth / 2;
  //   final halfVisibleHeight = visibleHeight / 2;

  //   // Calculate bounds
  //   final minX = halfVisibleWidth;
  //   final maxX = mapWidth - halfVisibleWidth;
  //   final minY = halfVisibleHeight;
  //   final maxY = mapHeight - halfVisibleHeight;

  //   // CRITICAL: Create a new Vector2 for the target position
  //   final targetX = player.position.x.clamp(minX, maxX);
  //   final targetY = player.position.y.clamp(minY, maxY);

  //   // CRITICAL: Force update the camera position directly
  //   cameraComponent.viewfinder.position = Vector2(targetX, targetY);

  //   debugPrint(
  //       'Camera position after update: ${cameraComponent.viewfinder.position}');
  // }

  // Method to switch to indoor scene
  void enterBuilding() {
    game.loadIndoorScene();
  }
}
