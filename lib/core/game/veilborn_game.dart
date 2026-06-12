import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../assets/asset_manager.dart';
import '../utils/constants.dart';

/// The main Flame game class for Veilborn.
///
/// Responsibilities:
/// - Manages the game lifecycle (onLoad, update, render)
/// - Preloads all assets via [AssetManager] before showing the world
/// - Orchestrates world, player, enemies, and UI overlays
/// - Handles game state transitions (menu → game → pause → game over)
class VeilbornGame extends FlameGame with HasKeyboardHandlerComponents {
  VeilbornGame({this.chapter = 1})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConstants.viewportWidth,
            height: GameConstants.viewportHeight,
          ),
        );

  /// Which chapter this session loads (1 or 2)
  final int chapter;

  /// Loading progress, 0.0–1.0 — bound to a loading overlay if shown.
  double loadProgress = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF0D0A14); // Void black

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ── Asset preload ──────────────────────────────────────
    // Show loading overlay while assets stream in. Safe no-op
    // if individual files are still placeholders (Phase 9 .gitkeep).
    try {
      overlays.add('Loading');
    } catch (_) {
      // Overlay not registered (e.g. in unit tests) — continue silently
    }

    await AssetManager.instance.preloadAll(
      onProgress: (pct) {
        loadProgress = pct;
      },
    );

    await AssetManager.instance.preloadChapter(chapter);

    try {
      overlays.remove('Loading');
    } catch (_) {
      // ignore if not present
    }

    // TODO Phase 10: Add world and player once sprite art is in place
    // world.add(LevelComponent(chapter: chapter, seed: DateTime.now().millisecondsSinceEpoch));
    // world.add(PlayerComponent(position: Vector2(40, 200)));

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
