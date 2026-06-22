import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/assets/asset_manifest.dart';
import '../audio/audio_manager.dart';
import '../audio/audio_provider.dart';
import '../save/save_manager.dart';
import '../../core/game/veilborn_game.dart';
import 'package:flame/game.dart';

// ══════════════════════════════════════════════════════════
// CHAPTER SELECT SCREEN
// ══════════════════════════════════════════════════════════
class ChapterSelectScreen extends StatefulWidget {
  const ChapterSelectScreen({super.key});

  @override
  State<ChapterSelectScreen> createState() => _ChapterSelectScreenState();
}

class _ChapterSelectScreenState extends State<ChapterSelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double>   _fade;
  int _highestChapter = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final save = SaveManager();
    await save.init();
    setState(() {
      _highestChapter = save.highestChapter;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _startChapter(int chapter) {
    AudioManager.instance.playSfx(SfxAssets.uiSelect);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _GameWrapper(chapter: chapter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF9A9AB0), size: 18),
          onPressed: () {
            AudioManager.instance.playSfx(SfxAssets.uiBack);
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Choose chapter',
          style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B3FA0)))
          : FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _ChapterCard(
                      number:    1,
                      title:     'Ashen Ruins',
                      subtitle:  'A collapsed fortress drowning in ash.',
                      boss:      'Ashen Warden',
                      isLocked:  false,
                      accentColor: const Color(0xFFEF9F27),
                      onTap:     () => _startChapter(1),
                    ),
                    const SizedBox(height: 16),
                    _ChapterCard(
                      number:    2,
                      title:     'Veil Sanctum',
                      subtitle:  'A cathedral where reality bleeds.',
                      boss:      'Veil Seraph',
                      isLocked:  _highestChapter < 2,
                      accentColor: const Color(0xFF6B3FA0),
                      onTap:     () => _startChapter(2),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.boss,
    required this.isLocked,
    required this.accentColor,
    required this.onTap,
  });

  final int        number;
  final String     title, subtitle, boss;
  final bool       isLocked;
  final Color      accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: isLocked ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF12101A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? const Color(0xFF2A2535)
                  : accentColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Chapter number
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: accentColor.withOpacity(0.3), width: 0.5),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Color(0xFFE8E4FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Color(0xFF5F5E5A), fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Boss  ',
                            style: TextStyle(
                                color: Color(0xFF3A3550), fontSize: 11)),
                        Text(boss,
                            style: TextStyle(
                                color: accentColor.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow / lock icon
              Icon(
                isLocked ? Icons.lock_outline : Icons.chevron_right,
                color: isLocked
                    ? const Color(0xFF3A3550)
                    : accentColor.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Game wrapper — mounts Flame GameWidget
class _GameWrapper extends StatefulWidget {
  const _GameWrapper({required this.chapter});
  final int chapter;

  @override
  State<_GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<_GameWrapper> {
  late final VeilbornGame _game;

  @override
  void initState() {
    super.initState();
    _game = VeilbornGame(chapter: widget.chapter);
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
      loadingBuilder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6B3FA0)),
      ),
      overlayBuilderMap: {
        'HudOverlay':        (_, __) => const SizedBox.shrink(),
        'GameOver':          (_, __) => const SizedBox.shrink(),
        'ChapterClear':      (_, __) => const SizedBox.shrink(),
        'RealityDistortion': (_, __) => const SizedBox.shrink(),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ══════════════════════════════════════════════════════════
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio   = ref.watch(audioProvider);
    final notifier = ref.read(audioProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF9A9AB0), size: 18),
          onPressed: () {
            AudioManager.instance.playSfx(SfxAssets.uiBack);
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFFE8E4FF), fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          // ── Audio ──────────────────────────────────────
          _SettingsSection(title: 'Audio'),
          _VolumeSlider(
            label: 'Master',
            value: audio.masterVolume,
            onChanged: (v) => notifier.setMaster(v),
          ),
          _VolumeSlider(
            label: 'Music',
            value: audio.musicVolume,
            onChanged: (v) => notifier.setMusic(v),
          ),
          _VolumeSlider(
            label: 'SFX',
            value: audio.sfxVolume,
            onChanged: (v) => notifier.setSfx(v),
          ),

          const SizedBox(height: 24),

          // ── Accessibility ──────────────────────────────
          _SettingsSection(title: 'Accessibility'),
          _ToggleSetting(
            label:    'Reduce motion',
            sublabel: 'Disables Sanity visual distortion effects',
            value:    false, // TODO: wire to SaveManager
            onChanged: (_) {},
          ),
          _ToggleSetting(
            label:    'Colour-blind mode',
            sublabel: 'Uses patterns in addition to colours',
            value:    false, // TODO: wire to SaveManager
            onChanged: (_) {},
          ),

          const SizedBox(height: 24),

          // ── Controls ───────────────────────────────────
          _SettingsSection(title: 'Controls'),
          _SliderSetting(
            label:    'Button size',
            sublabel: 'Adjusts virtual button size on mobile',
            value:    0.5,
            onChanged: (_) {},
          ),

          const SizedBox(height: 40),

          // ── Version ────────────────────────────────────
          const Center(
            child: Text(
              'Veilborn v0.1.0 · AI Game Studio',
              style: TextStyle(color: Color(0xFF2A2535), fontSize: 11),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Settings widgets ──────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF5F5E5A),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: .08,
      ),
    ),
  );
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String   label;
  final double   value;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF9A9AB0), fontSize: 13)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight:          2,
              activeTrackColor:     const Color(0xFF6B3FA0),
              inactiveTrackColor:   const Color(0xFF2A2535),
              thumbColor:           const Color(0xFFE8E4FF),
              thumbShape:           const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape:         const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
                color: Color(0xFF5F5E5A), fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _ToggleSetting extends StatelessWidget {
  const _ToggleSetting({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });
  final String   label, sublabel;
  final bool     value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFFE8E4FF), fontSize: 13)),
              Text(sublabel,
                  style: const TextStyle(
                      color: Color(0xFF5F5E5A), fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value:     value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6B3FA0),
          inactiveTrackColor: const Color(0xFF2A2535),
          inactiveThumbColor: const Color(0xFF5F5E5A),
        ),
      ],
    ),
  );
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });
  final String   label, sublabel;
  final double   value;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              color: Color(0xFFE8E4FF), fontSize: 13)),
      Text(sublabel,
          style: const TextStyle(
              color: Color(0xFF5F5E5A), fontSize: 11)),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight:        2,
          activeTrackColor:   const Color(0xFF6B3FA0),
          inactiveTrackColor: const Color(0xFF2A2535),
          thumbColor:         const Color(0xFFE8E4FF),
        ),
        child: Slider(value: value, onChanged: onChanged),
      ),
    ],
  );
}
