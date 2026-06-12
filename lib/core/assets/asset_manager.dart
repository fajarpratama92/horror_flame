import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'asset_manifest.dart';

/// Manages preloading and caching of all Veilborn assets.
///
/// Usage — in VeilbornGame.onLoad():
/// ```dart
/// await AssetManager.instance.preloadAll(
///     onProgress: (pct) => setState(() => _loadProgress = pct),
/// );
/// ```
///
/// Graceful degradation: if an asset file is missing (placeholder .gitkeep
/// in place during development), the load is skipped and a warning is logged.
/// The game continues with the existing RectangleComponent placeholders.
class AssetManager {
  AssetManager._();
  static final AssetManager instance = AssetManager._();

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ── Preload everything ────────────────────────────────────────
  Future<void> preloadAll({
    void Function(double progress)? onProgress,
  }) async {
    if (_loaded) return;

    final groups = [
      _Group('Player sprites',     () => _loadImages(PlayerAssets.all)),
      _Group('Enemy sprites',      () => _loadImages(EnemyAssets.all)),
      _Group('Boss sprites',       () => _loadImages(BossAssets.all)),
      _Group('UI assets',          () => _loadImages(UiAssets.all)),
      _Group('Backgrounds',        () => _loadImages(BackgroundAssets.all)),
      _Group('Sound effects',      () => _loadSfx(SfxAssets.all)),
      _Group('Music',              () => _loadBgm(BgmAssets.all)),
    ];

    final total = groups.length.toDouble();
    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      debugPrint('[Assets] Loading ${group.name}…');
      try {
        await group.loader();
      } catch (e) {
        debugPrint('[Assets] ⚠️  ${group.name} partially failed: $e');
      }
      onProgress?.call((i + 1) / total);
    }

    _loaded = true;
    debugPrint('[Assets] ✅ All asset groups loaded');
  }

  // ── Chapter-specific preload (lazy, called on chapter start) ──
  Future<void> preloadChapter(int chapter) async {
    debugPrint('[Assets] Preloading Chapter $chapter tiles…');
    // Tiled maps are loaded on demand by LevelComponent
    // This warms the images cache for the chapter tileset
    if (chapter == 1) {
      await _loadImageSafe(BackgroundAssets.ch1Sky);
      await _loadImageSafe(BackgroundAssets.ch1MidLayer);
      await _loadImageSafe(BackgroundAssets.ch1ForeLayer);
    } else if (chapter == 2) {
      await _loadImageSafe(BackgroundAssets.ch2Sky);
      await _loadImageSafe(BackgroundAssets.ch2MidLayer);
      await _loadImageSafe(BackgroundAssets.ch2ForeLayer);
    }
  }

  // ── Preload just what the main menu needs ─────────────────────
  Future<void> preloadMainMenu() async {
    await _loadImageSafe(UiAssets.candleFlame);
    await _loadBgmSafe(BgmAssets.mainMenu);
  }

  // ── Helpers ───────────────────────────────────────────────────
  Future<void> _loadImages(List<String> paths) async {
    for (final path in paths) {
      await _loadImageSafe(path);
    }
  }

  Future<void> _loadImageSafe(String path) async {
    try {
      await Flame.images.load(path);
    } catch (e) {
      // File not yet created — placeholder active
      debugPrint('[Assets]   skip image: $path (${_shortError(e)})');
    }
  }

  Future<void> _loadSfx(List<String> paths) async {
    for (final path in paths) {
      try {
        await FlameAudio.audioCache.load(path);
      } catch (e) {
        debugPrint('[Assets]   skip sfx: $path (${_shortError(e)})');
      }
    }
  }

  Future<void> _loadBgm(List<String> paths) async {
    for (final path in paths) {
      await _loadBgmSafe(path);
    }
  }

  Future<void> _loadBgmSafe(String path) async {
    try {
      await FlameAudio.audioCache.load(path);
    } catch (e) {
      debugPrint('[Assets]   skip bgm: $path (${_shortError(e)})');
    }
  }

  String _shortError(Object e) {
    final s = e.toString();
    return s.length > 60 ? '${s.substring(0, 60)}…' : s;
  }

  // ── Cache queries (used by component onLoad methods) ──────────

  /// Returns true if an image was successfully preloaded.
  bool isImageLoaded(String path) {
    try {
      Flame.images.fromCache(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _Group {
  const _Group(this.name, this.loader);
  final String name;
  final Future<void> Function() loader;
}
