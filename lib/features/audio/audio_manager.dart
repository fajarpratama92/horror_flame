import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// SFX identifiers — filenames under assets/audio/sfx/
class Sfx {
  Sfx._();
  static const String playerAttackLight  = 'sfx_attack_light.ogg';
  static const String playerAttackHeavy  = 'sfx_attack_heavy.ogg';
  static const String playerAttackRanged = 'sfx_attack_ranged.ogg';
  static const String playerHit          = 'sfx_player_hit.ogg';
  static const String playerDash         = 'sfx_dash.ogg';
  static const String playerDeath        = 'sfx_player_death.ogg';
  static const String enemyHit           = 'sfx_enemy_hit.ogg';
  static const String enemyDeath         = 'sfx_enemy_death.ogg';
  static const String bossPhaseShift     = 'sfx_boss_phase.ogg';
  static const String sanityDrain        = 'sfx_sanity_drain.ogg';
  static const String soulEssencePick    = 'sfx_soul_essence.ogg';
  static const String levelComplete      = 'sfx_level_complete.ogg';
  static const String uiSelect           = 'sfx_ui_select.ogg';
  static const String uiBack             = 'sfx_ui_back.ogg';
  static const String skillSelect        = 'sfx_skill_select.ogg';
  static const String purchaseSuccess    = 'sfx_purchase.ogg';

  static const List<String> all = [
    playerAttackLight, playerAttackHeavy, playerAttackRanged,
    playerHit, playerDash, playerDeath,
    enemyHit, enemyDeath, bossPhaseShift,
    sanityDrain, soulEssencePick, levelComplete,
    uiSelect, uiBack, skillSelect, purchaseSuccess,
  ];
}

/// BGM track identifiers — filenames under assets/audio/music/
class Bgm {
  Bgm._();
  static const String mainMenu       = 'bgm_main_menu.ogg';
  static const String ch1Explore     = 'bgm_ch1_explore.ogg';
  static const String ch1Boss        = 'bgm_ch1_boss.ogg';
  static const String ch2Explore     = 'bgm_ch2_explore.ogg';
  static const String ch2Boss        = 'bgm_ch2_boss.ogg';
  static const String gameOver       = 'bgm_game_over.ogg';
}

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
      await FlameAudio.audioCache.loadAll(Sfx.all);
      _initialized = true;
      debugPrint('[Audio] Initialized — ${Sfx.all.length} SFX cached');
    } catch (e) {
      // Audio may not be available in test environments
      debugPrint('[Audio] Init warning: $e');
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
    if (!_initialized) return; // not initialised yet — safe no-op
    FlameAudio.bgm.audioPlayer!.setVolume(_effectiveMusicVolume);
  }

  // ── BGM ───────────────────────────────────────────────────
  Future<void> playBgm(String track, {bool loop = true}) async {
    if (!_initialized) return;
    if (_currentBgm == track) return; // Already playing

    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(track, volume: _effectiveMusicVolume);
      _currentBgm = track;
      debugPrint('[Audio] BGM → $track');
    } catch (e) {
      debugPrint('[Audio] BGM error: $e');
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
  /// Called by SurvivalController when sanity threshold changes.
  ///
  /// Applies pitch/reverb/volume effects to simulate psychological distortion.
  /// Respects reduceMotion setting — uses volume only if motion is reduced.
  void onSanityThresholdChanged(int threshold, {bool reduceMotion = false}) {
    if (!_initialized) return;
    if (reduceMotion) {
      // Subtle volume shift only
      final vol = switch (threshold) {
        0 => _effectiveMusicVolume,
        1 => _effectiveMusicVolume * 0.9,
        2 => _effectiveMusicVolume * 0.75,
        3 => _effectiveMusicVolume * 0.6,
        _ => _effectiveMusicVolume,
      };
      FlameAudio.bgm.audioPlayer!.setVolume(vol);
      return;
    }

    // Full effect: volume + playback rate (simulates pitch shift)
    final (vol, rate) = switch (threshold) {
      0 => (_effectiveMusicVolume,        1.00), // normal
      1 => (_effectiveMusicVolume * 0.85, 0.97), // mid — subtle slowdown
      2 => (_effectiveMusicVolume * 0.70, 0.93), // low — warping
      3 => (_effectiveMusicVolume * 0.55, 0.88), // critical — heavy distortion
      _ => (_effectiveMusicVolume,        1.00),
    };

    if (!_initialized) return;
    FlameAudio.bgm.audioPlayer!.setVolume(vol);
    FlameAudio.bgm.audioPlayer!.setPlaybackRate(rate);
    debugPrint('[Audio] Sanity fx: vol=$vol rate=$rate');
  }

  /// Restore normal BGM after sanity recovers
  void restoreBgm() {
    if (!_initialized) return;
    FlameAudio.bgm.audioPlayer!.setVolume(_effectiveMusicVolume);
    FlameAudio.bgm.audioPlayer!.setPlaybackRate(1.0);
  }

  // ── App lifecycle ─────────────────────────────────────────
  void onAppPaused()   => pauseBgm();
  void onAppResumed()  => resumeBgm();

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}
