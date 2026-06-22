import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../../features/level/level_component.dart';
import '../../features/player/player_component.dart';
import '../assets/asset_manager.dart';
import '../utils/constants.dart';

/// The main Flame game class for Veilborn.
class VeilbornGame extends FlameGame with HasKeyboardHandlerComponents {
  VeilbornGame({this.chapter = 1})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConstants.viewportWidth,
            height: GameConstants.viewportHeight,
          ),
        );

  final int chapter;
  double loadProgress = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF0D0A14); // Void black

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      overlays.add('Loading');
    } catch (_) {}

    debugPrint('[Game] Starting onLoad sequence…');

    await AssetManager.instance.preloadAll(
      onProgress: (pct) {
        loadProgress = pct;
      },
    );

    await AssetManager.instance.preloadChapter(chapter);

    try {
      overlays.remove('Loading');
    } catch (_) {}

    debugPrint('[Game] Adding LevelComponent…');
    await world.add(LevelComponent(
      chapter: chapter, 
      seed: DateTime.now().millisecondsSinceEpoch,
    ));
    
    debugPrint('[Game] Adding PlayerComponent…');
    await world.add(PlayerComponent(
      position: Vector2(40, 200),
    ));

    try {
      overlays.add('HudOverlay');
    } catch (_) {}

    debugPrint('[Game] onLoad sequence complete');
    
    // Set to true to see hitboxes and help debug the "black screen"
    debugMode = true; 
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void pauseGame() {
    pauseEngine();
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    resumeEngine();
    overlays.remove('PauseMenu');
  }

  void gameOver() {
    pauseEngine();
    overlays.add('GameOver');
  }
}
