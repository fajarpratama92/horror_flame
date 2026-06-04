import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import '../../core/components/physics_body.dart';
import '../enemy/wanderer.dart';
import '../enemy/wraith.dart';

/// Procedurally assembles a chapter run from hand-crafted Tiled room chunks.
///
/// Strategy:
/// - Pool of [chunksPerChapter] pre-built .tmx files per chapter
/// - Shuffle pool each run (seeded for reproducibility)
/// - First chunk: always mild opener (index 0)
/// - Last chunk: always gauntlet (index -1)
/// - Middle chunks: randomly ordered from the pool
///
/// Each chunk is stacked horizontally — the camera scrolls right.
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
    await _assembleChunks();
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
    // TMX file names by chapter
    // TODO: replace with real files under assets/tiles/
    return switch (chap) {
      1 => [
        'ch1_opener.tmx',
        'ch1_combat_a.tmx',
        'ch1_platform_b.tmx',
        'ch1_hybrid_c.tmx',
        'ch1_dark_zone.tmx',
        'ch1_safe_room.tmx',
        'ch1_gauntlet.tmx',
      ],
      2 => [
        'ch2_opener.tmx',
        'ch2_combat_a.tmx',
        'ch2_platform_b.tmx',
        'ch2_veil_rift.tmx',
        'ch2_dark_zone.tmx',
        'ch2_safe_room.tmx',
        'ch2_gauntlet.tmx',
      ],
      _ => ['ch1_opener.tmx'],
    };
  }

  /// Camera follow — returns the world X boundary of the current chunk
  double get totalWidth =>
      _chunks.fold(0, (sum, c) => sum + c.chunkWidth);
}

// ── Room chunk ────────────────────────────────────────────
class RoomChunk extends Component with HasGameRef {
  RoomChunk({required this.tmxFile, required this.xOffset});

  final String tmxFile;
  final double xOffset;

  double get chunkWidth => _map?.tileMap.map.width  *
      (_map?.tileMap.map.tileWidth  ?? 16).toDouble() ?? 480.0;

  TiledComponent? _map;

  bool get isSafeRoom  => tmxFile.contains('safe_room');
  bool get isDarkZone  => tmxFile.contains('dark_zone') ||
                          tmxFile.contains('veil_rift');

  @override
  Future<void> onLoad() async {
    try {
      _map = await TiledComponent.load(
        tmxFile,
        Vector2.all(16), // tile size 16×16
      );
      _map!.x = xOffset;
      add(_map!);
      _spawnCollidersFrom(_map!);
      _spawnEnemiesFrom(_map!);
    } catch (_) {
      // Placeholder while real TMX files are not yet present
      _addPlaceholderRoom();
    }
  }

  void _spawnCollidersFrom(TiledComponent map) {
    // Read 'Collision' object layer from Tiled map
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
  }

  void _spawnEnemiesFrom(TiledComponent map) {
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
  }

  void _addPlaceholderRoom() {
    // Flat floor platform when TMX files not yet present
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
    // TODO: load boss room TMX + spawn appropriate boss component
    // Chapter 1 → AshenWarden; Chapter 2 → VeilSeraph
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
