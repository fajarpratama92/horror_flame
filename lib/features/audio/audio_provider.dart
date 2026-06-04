import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_manager.dart';
import '../save/save_manager.dart';

/// Riverpod provider for audio settings — volume sliders, mute state.
class AudioNotifier extends Notifier<AudioState> {
  late final SaveManager _save;

  @override
  AudioState build() {
    _save = SaveManager();
    // SaveManager already initialized by ShopProvider — safe to use
    final settings = _save.settings;
    return AudioState(
      masterVolume: settings.masterVolume,
      sfxVolume:    settings.sfxVolume,
      musicVolume:  settings.musicVolume,
    );
  }

  Future<void> setMaster(double v) async {
    state = state.copyWith(masterVolume: v);
    AudioManager.instance.setMasterVolume(v);
    await _persist();
  }

  Future<void> setSfx(double v) async {
    state = state.copyWith(sfxVolume: v);
    AudioManager.instance.setSfxVolume(v);
    await _persist();
  }

  Future<void> setMusic(double v) async {
    state = state.copyWith(musicVolume: v);
    AudioManager.instance.setMusicVolume(v);
    await _persist();
  }

  Future<void> _persist() async {
    await _save.saveSettings(
      _save.settings.copyWith(
        masterVolume: state.masterVolume,
        sfxVolume:    state.sfxVolume,
        musicVolume:  state.musicVolume,
      ),
    );
  }
}

final audioProvider =
    NotifierProvider<AudioNotifier, AudioState>(AudioNotifier.new);

class AudioState {
  const AudioState({
    required this.masterVolume,
    required this.sfxVolume,
    required this.musicVolume,
  });

  final double masterVolume;
  final double sfxVolume;
  final double musicVolume;

  AudioState copyWith({
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
  }) => AudioState(
    masterVolume: masterVolume ?? this.masterVolume,
    sfxVolume:    sfxVolume    ?? this.sfxVolume,
    musicVolume:  musicVolume  ?? this.musicVolume,
  );
}
