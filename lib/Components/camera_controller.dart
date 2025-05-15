import 'package:flame/components.dart';
import 'package:melody_house_demo/Components/player_component.dart';

class CameraController extends Component with HasGameReference {
  final Player player;
  final double mapWidth;
  final double mapHeight;
  final CameraComponent camera;

  CameraController({
    required this.player,
    required this.mapWidth,
    required this.mapHeight,
    required this.camera,
  });

  @override
  void update(double dt) {
    super.update(dt);

    // Get the visible area dimensions based on camera zoom
    final visibleWidth = game.size.x / camera.viewfinder.zoom;
    final visibleHeight = game.size.y / camera.viewfinder.zoom;

    // Calculate the half sizes for centering
    final halfVisibleWidth = visibleWidth / 2;
    final halfVisibleHeight = visibleHeight / 2;

    // Calculate the bounds for the camera target
    final minX = halfVisibleWidth;
    final maxX = mapWidth - halfVisibleWidth;
    final minY = halfVisibleHeight;
    final maxY = mapHeight - halfVisibleHeight;

    // Get the player position
    final playerX = player.position.x;
    final playerY = player.position.y;

    // Calculate the constrained target position
    final targetX = playerX.clamp(minX, maxX);
    final targetY = playerY.clamp(minY, maxY);

    camera.viewfinder.position = Vector2(targetX, targetY);

    // // Set the camera position directly
    // camera.viewfinder.position.x = newX;
    // camera.viewfinder.position.y = newY;

    // debugPrint(
    //     'Camera position: ${camera.viewfinder.position}, Player: ${player.position}');
  }
}
