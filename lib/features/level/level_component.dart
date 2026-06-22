import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import '../../core/assets/asset_manifest.dart';
import '../../core/components/physics_body.dart';
import '../enemy/wanderer.dart';
import '../enemy/wraith.dart';

/// Procedurally assembles a chapter run from hand-crafted Tiled room chunks.
class LevelComponent extends Component with HasGameRef {
  LevelComponent({
    required this.chapter,
    required this.seed,
  });

  final int    chapter;
  final int    seed;
  static const int segmentsPerRun = 5;

  final List<RoomChunk> _chunks = [];

  // Tracks whether player is in a dark zone / safe room for Sanity
  bool inDarkZone  = false;
  bool inSafeRoom  = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugPrint('[Level] Loading chapter $chapter (seed: $seed)…');
    await _assembleChunks();
    debugPrint('[Level] Chapter $chapter assembly complete');
  }

  Future<void> _assembleChunks() async {
    final rng   = Random(seed);
    final pool  = _chunkFilesFor(chapter);

    // Build ordered chunk list: opener + shuffled middle + gauntlet
    final opener   = pool.first;
    final gauntlet = pool.last;
    final middle   = pool.sublist(1, pool.length - 1)..shuffle(rng);
    final selected = [
      opener,
      ...middle.take(segmentsPerRun - 2),
      gauntlet,
    ];

    double xOffset = 0;
    for (final file in selected) {
      final chunk = RoomChunk(tmxFile: file, xOffset: xOffset);
      await add(chunk);
      _chunks.add(chunk);
      xOffset += chunk.chunkWidth;
    }

    // Boss room at the end
    final boss = BossRoomChunk(
      chapter: chapter,
      xOffset: xOffset,
    );
    await add(boss);
  }

  List<String> _chunkFilesFor(int chap) {
    // We use the paths defined in TileAssets manifest
    return switch (chap) {
      1 => [
        TileAssets.ch1Opener,
        TileAssets.ch1CombatA,
        TileAssets.ch1PlatformB,
        TileAssets.ch1HybridC,
        TileAssets.ch1DarkZone,
        TileAssets.ch1SafeRoom,
        TileAssets.ch1Gauntlet,
      ],
      2 => [
        TileAssets.ch2Opener,
        TileAssets.ch2CombatA,
        TileAssets.ch2PlatformB,
        TileAssets.ch2VeilRift,
        TileAssets.ch2DarkZone,
        TileAssets.ch2SafeRoom,
        TileAssets.ch2Gauntlet,
      ],
      _ => [TileAssets.ch1Opener],
    };
  }

  double get totalWidth =>
      _chunks.fold(0, (sum, c) => sum + c.chunkWidth);
}

// ── Room chunk ────────────────────────────────────────────
class RoomChunk extends Component with HasGameRef {
  RoomChunk({required this.tmxFile, required this.xOffset});

  final String tmxFile;
  final double xOffset;

  double get chunkWidth {
    final m = _map;
    if (m == null) return 480.0;
    return (m.tileMap.map.width * m.tileMap.map.tileWidth).toDouble();
  }

  TiledComponent? _map;

  @override
  Future<void> onLoad() async {
    debugPrint('[Level]   loading chunk: $tmxFile…');
    try {
      _map = await TiledComponent.load(
        tmxFile,
        Vector2.all(16),
      );
      _map!.position = Vector2(xOffset, 0);
      add(_map!);
      _spawnCollidersFrom(_map!);
      _spawnEnemiesFrom(_map!);
      debugPrint('[Level]   ✅ chunk ready: $tmxFile');
    } catch (e) {
      debugPrint('[Level]   ⚠️  chunk failed: $tmxFile — using placeholder ($e)');
      _addPlaceholderRoom();
    }
  }

  void _spawnCollidersFrom(TiledComponent map) {
    try {
      final objectLayer = map.tileMap.getLayer<ObjectGroup>('Collision');
      if (objectLayer == null) return;

      for (final obj in objectLayer.objects) {
        add(
          PositionComponent(
            position: Vector2(xOffset + obj.x, obj.y),
            size: Vector2(obj.width, obj.height),
            children: [PlatformHitbox(size: Vector2(obj.width, obj.height))],
          ),
        );
      }
    } catch (_) {}
  }

  void _spawnEnemiesFrom(TiledComponent map) {
    try {
      final spawnLayer = map.tileMap.getLayer<ObjectGroup>('Enemies');
      if (spawnLayer == null) return;

      for (final obj in spawnLayer.objects) {
        final pos = Vector2(xOffset + obj.x, obj.y);
        final enemy = switch (obj.name) {
          'Wanderer' => Wanderer(position: pos),
          'Wraith'   => Wraith(position: pos),
          _          => Wanderer(position: pos),
        };
        gameRef.world.add(enemy);
      }
    } catch (_) {}
  }

  void _addPlaceholderRoom() {
    add(
      PositionComponent(
        position: Vector2(xOffset, 230),
        size: Vector2(480, 16),
        children: [
          RectangleComponent(
            size: Vector2(480, 16),
            paint: Paint()..color = const Color(0xFF3A3550),
          ),
          PlatformHitbox(size: Vector2(480, 16)),
        ],
      ),
    );
  }
}

// ── Boss room ─────────────────────────────────────────────
class BossRoomChunk extends Component with HasGameRef {
  BossRoomChunk({required this.chapter, required this.xOffset});

  final int    chapter;
  final double xOffset;

  @override
  Future<void> onLoad() async {
    _addPlaceholderBossRoom();
  }

  void _addPlaceholderBossRoom() {
    add(
      PositionComponent(
        position: Vector2(xOffset, 200),
        size: Vector2(480, 16),
        children: [
          RectangleComponent(
            size: Vector2(480, 16),
            paint: Paint()..color = const Color(0xFF6B3FA0),
          ),
          PlatformHitbox(size: Vector2(480, 16)),
        ],
      ),
    );
  }
}
