import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages all local save/load operations via SharedPreferences.
///
/// Saved data:
/// - Unlocked cosmetics (skins)
/// - Highest chapter reached
/// - Total runs completed
/// - Settings (audio, controls)
///
/// NOTE: Run-in-progress state is kept in memory only.
/// SharedPreferences is for persistent meta-progression only.
class SaveManager {
  static const String _keyUnlockedSkins   = 'unlocked_skins';
  static const String _keyHighestChapter  = 'highest_chapter';
  static const String _keyTotalRuns       = 'total_runs';
  static const String _keySettings        = 'settings';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  void _assertInit() {
    assert(_initialized, 'SaveManager.init() must be called before use.');
  }

  // ── Cosmetics ─────────────────────────────────────────────
  List<String> get unlockedSkins {
    _assertInit();
    return _prefs.getStringList(_keyUnlockedSkins) ?? ['ashen_knight'];
  }

  Future<void> unlockSkin(String skinId) async {
    _assertInit();
    final current = unlockedSkins;
    if (!current.contains(skinId)) {
      current.add(skinId);
      await _prefs.setStringList(_keyUnlockedSkins, current);
    }
  }

  bool isSkinUnlocked(String skinId) => unlockedSkins.contains(skinId);

  // ── Progression ───────────────────────────────────────────
  int get highestChapter {
    _assertInit();
    return _prefs.getInt(_keyHighestChapter) ?? 1;
  }

  Future<void> setHighestChapter(int chapter) async {
    _assertInit();
    if (chapter > highestChapter) {
      await _prefs.setInt(_keyHighestChapter, chapter);
    }
  }

  int get totalRuns {
    _assertInit();
    return _prefs.getInt(_keyTotalRuns) ?? 0;
  }

  Future<void> incrementRuns() async {
    _assertInit();
    await _prefs.setInt(_keyTotalRuns, totalRuns + 1);
  }

  // ── Settings ──────────────────────────────────────────────
  GameSettings get settings {
    _assertInit();
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const GameSettings();
    return GameSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(GameSettings s) async {
    _assertInit();
    await _prefs.setString(_keySettings, jsonEncode(s.toJson()));
  }

  // ── Full reset (for testing) ──────────────────────────────
  Future<void> reset() async {
    _assertInit();
    await _prefs.clear();
  }
}

class GameSettings {
  const GameSettings({
    this.masterVolume = 1.0,
    this.sfxVolume    = 1.0,
    this.musicVolume  = 0.7,
    this.reduceMotion = false,
    this.colorBlindMode = false,
  });

  final double masterVolume;
  final double sfxVolume;
  final double musicVolume;
  final bool   reduceMotion;
  final bool   colorBlindMode;

  Map<String, dynamic> toJson() => {
    'masterVolume':   masterVolume,
    'sfxVolume':      sfxVolume,
    'musicVolume':    musicVolume,
    'reduceMotion':   reduceMotion,
    'colorBlindMode': colorBlindMode,
  };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
    masterVolume:   (json['masterVolume']   as num?)?.toDouble() ?? 1.0,
    sfxVolume:      (json['sfxVolume']      as num?)?.toDouble() ?? 1.0,
    musicVolume:    (json['musicVolume']    as num?)?.toDouble() ?? 0.7,
    reduceMotion:   json['reduceMotion']   as bool? ?? false,
    colorBlindMode: json['colorBlindMode'] as bool? ?? false,
  );

  GameSettings copyWith({
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
    bool?   reduceMotion,
    bool?   colorBlindMode,
  }) => GameSettings(
    masterVolume:   masterVolume   ?? this.masterVolume,
    sfxVolume:      sfxVolume      ?? this.sfxVolume,
    musicVolume:    musicVolume    ?? this.musicVolume,
    reduceMotion:   reduceMotion   ?? this.reduceMotion,
    colorBlindMode: colorBlindMode ?? this.colorBlindMode,
  );
}
