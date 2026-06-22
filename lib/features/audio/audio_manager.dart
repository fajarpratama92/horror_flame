import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import '../../core/assets/asset_manifest.dart';

/// AudioManager — singleton that wraps FlameAudio.
///
/// Features:
/// - BGM crossfade between tracks
/// - SFX playback with volume control
/// - Sanity-reactive music: shifts BGM volume/pitch at thresholds
/// - All volume settings respected from GameSettings
class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  double _masterVolume = 1.0;
  double _sfxVolume    = 1.0;
  double _musicVolume  = 0.7;
  bool   _initialized  = false;

  String? _currentBgm;

  // ── Init ──────────────────────────────────────────────────
  Future<void> init({
    double master = 1.0,
    double sfx    = 1.0,
    double music  = 0.7,
  }) async {
    _masterVolume = master;
    _sfxVolume    = sfx;
    _musicVolume  = music;

    try {
      // Pre-cache all SFX for zero-latency playback
      // We use SfxAssets.all from the manifest which has correct paths
      await FlameAudio.audioCache.loadAll(SfxAssets.all);
      _initialized = true;
      debugPrint('[Audio] Initialized — ${SfxAssets.all.length} SFX cached');
    } catch (e) {
      // Audio may not be available in test environments
      debugPrint('[Audio] Init warning: $e');
      // Set to true anyway to allow BGM to try and play, 
      // FlameAudio is usually robust enough to handle missing files on the fly.
      _initialized = true; 
    }
  }

  // ── Volume control ────────────────────────────────────────
  void setMasterVolume(double v) {
    _masterVolume = v.clamp(0.0, 1.0);
    _applyBgmVolume();
  }

  void setSfxVolume(double v) {
    _sfxVolume = v.clamp(0.0, 1.0);
  }

  void setMusicVolume(double v) {
    _musicVolume = v.clamp(0.0, 1.0);
    _applyBgmVolume();
  }

  double get _effectiveMusicVolume => _masterVolume * _musicVolume;
  double get _effectiveSfxVolume   => _masterVolume * _sfxVolume;

  void _applyBgmVolume() {
    if (!_initialized) return; 
    FlameAudio.bgm.audioPlayer.setVolume(_effectiveMusicVolume);
  }

  // ── BGM ───────────────────────────────────────────────────
  Future<void> playBgm(String track, {bool loop = true}) async {
    if (!_initialized) {
      debugPrint('[Audio] skip playBgm: not initialized');
      return;
    }
    if (_currentBgm == track) return; 

    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(track, volume: _effectiveMusicVolume);
      _currentBgm = track;
      debugPrint('[Audio] BGM → $track');
    } catch (e) {
      debugPrint('[Audio] BGM error ($track): $e');
    }
  }

  Future<void> stopBgm() async {
    if (!_initialized) return;
    await FlameAudio.bgm.stop();
    _currentBgm = null;
  }

  Future<void> pauseBgm()  async => FlameAudio.bgm.pause();
  Future<void> resumeBgm() async => FlameAudio.bgm.resume();

  // ── SFX ───────────────────────────────────────────────────
  void playSfx(String sfxFile) {
    if (!_initialized || _effectiveSfxVolume == 0) return;
    try {
      FlameAudio.play(sfxFile, volume: _effectiveSfxVolume);
    } catch (e) {
      debugPrint('[Audio] SFX error ($sfxFile): $e');
    }
  }

  // ── Sanity-reactive music ─────────────────────────────────
  void onSanityThresholdChanged(int threshold, {bool reduceMotion = false}) {
    if (!_initialized) return;
    if (reduceMotion) {
      final vol = switch (threshold) {
        0 => _effectiveMusicVolume,
        1 => _effectiveMusicVolume * 0.9,
        2 => _effectiveMusicVolume * 0.75,
        3 => _effectiveMusicVolume * 0.6,
        _ => _effectiveMusicVolume,
      };
      FlameAudio.bgm.audioPlayer.setVolume(vol);
      return;
    }

    final (vol, rate) = switch (threshold) {
      0 => (_effectiveMusicVolume,        1.00), 
      1 => (_effectiveMusicVolume * 0.85, 0.97), 
      2 => (_effectiveMusicVolume * 0.70, 0.93), 
      3 => (_effectiveMusicVolume * 0.55, 0.88), 
      _ => (_effectiveMusicVolume,        1.00),
    };

    FlameAudio.bgm.audioPlayer.setVolume(vol);
    FlameAudio.bgm.audioPlayer.setPlaybackRate(rate);
  }

  void restoreBgm() {
    if (!_initialized) return;
    FlameAudio.bgm.audioPlayer.setVolume(_effectiveMusicVolume);
    FlameAudio.bgm.audioPlayer.setPlaybackRate(1.0);
  }

  void onAppPaused()   => pauseBgm();
  void onAppResumed()  => resumeBgm();

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}
