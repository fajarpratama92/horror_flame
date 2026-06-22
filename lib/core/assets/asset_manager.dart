import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'asset_manifest.dart';

/// Manages preloading and caching of all Veilborn assets.
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
      _Group('Sound effects',      () => _loadSfx(SfxAssets.all)),
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
    debugPrint('[Assets] ✅ All critical asset groups loaded');
  }

  // ── Chapter-specific preload ──
  Future<void> preloadChapter(int chapter) async {
    debugPrint('[Assets] Preloading Chapter $chapter background layers…');
    if (chapter == 1) {
      await Future.wait([
        _loadImageSafe(BackgroundAssets.ch1Sky),
        _loadImageSafe(BackgroundAssets.ch1MidLayer),
        _loadImageSafe(BackgroundAssets.ch1ForeLayer),
      ]);
    } else if (chapter == 2) {
      await Future.wait([
        _loadImageSafe(BackgroundAssets.ch2Sky),
        _loadImageSafe(BackgroundAssets.ch2MidLayer),
        _loadImageSafe(BackgroundAssets.ch2ForeLayer),
      ]);
    }
    debugPrint('[Assets] Chapter $chapter pre-warm complete');
  }

  Future<void> preloadMainMenu() async {
    await _loadImageSafe(UiAssets.candleFlame);
  }

  // ── Helpers ───────────────────────────────────────────────────
  Future<void> _loadImages(List<String> paths) async {
    await Future.wait(paths.map((p) => _loadImageSafe(p)));
  }

  Future<void> _loadImageSafe(String path) async {
    try {
      debugPrint('[Assets]   loading: $path');
      await Flame.images.load(path);
    } catch (e) {
      debugPrint('[Assets]   ❌ skip: $path (${_shortError(e)})');
    }
  }

  Future<void> _loadSfx(List<String> paths) async {
    try {
      await FlameAudio.audioCache.loadAll(paths);
    } catch (e) {
      debugPrint('[Assets]   ❌ skip sfx group (${_shortError(e)})');
    }
  }

  String _shortError(Object e) {
    final s = e.toString();
    return s.length > 60 ? '${s.substring(0, 60)}…' : s;
  }

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
