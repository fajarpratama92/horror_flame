import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// The main Flame game class for Veilborn.
///
/// Responsibilities:
/// - Manages the game lifecycle (onLoad, update, render)
/// - Orchestrates world, player, enemies, and UI overlays
/// - Handles game state transitions (menu → game → pause → game over)
class VeilbornGame extends FlameGame with HasKeyboardHandlerComponents {
  VeilbornGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConstants.viewportWidth,
            height: GameConstants.viewportHeight,
          ),
        );

  @override
  Color backgroundColor() => const Color(0xFF0D0A14); // Void black

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // TODO Phase 5: Load assets
    // await images.loadAllImages();
    // await FlameAudio.audioCache.loadAll([...]);

    // TODO Phase 5: Add world and player
    // world.add(LevelComponent());
    // world.add(PlayerComponent());

    // Show HUD (guarded for test environments)
    try {
      overlays.add('HudOverlay');
    } catch (_) {
      // Overlay not registered in test environment — safe to ignore
    }

    debugMode = false; // Set to true during development to see hitboxes
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Global update logic (sanity effects, camera shake, etc.) goes here
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
