import 'package:flutter/material.dart';
import '../../core/game/veilborn_game.dart';

/// Loading overlay — shown while [AssetManager] preloads sprites/audio.
///
/// Polls `game.loadProgress` via a periodic timer since Flame overlays
/// don't auto-rebuild on field mutation.
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key, required this.game});

  final VeilbornGame game;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  late final Ticker _ticker;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((_) {
      if (mounted && widget.game.loadProgress != _progress) {
        setState(() => _progress = widget.game.loadProgress);
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0A14),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'VEILBORN',
              style: TextStyle(
                color: Color(0xFFE8E4FF),
                fontSize: 28,
                fontWeight: FontWeight.w200,
                letterSpacing: .35,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 3,
                  backgroundColor: const Color(0xFF1A1626),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6B3FA0)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                color: Color(0xFF5F5E5A),
                fontSize: 11,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal ticker without requiring a TickerProvider mixin —
/// used for polling [VeilbornGame.loadProgress] in the overlay.
class Ticker {
  Ticker(this._onTick);
  final void Function(Duration) _onTick;
  bool _active = false;

  void start() {
    _active = true;
    _tick(Duration.zero);
  }

  void _tick(Duration elapsed) {
    if (!_active) return;
    _onTick(elapsed);
    Future.delayed(const Duration(milliseconds: 100), () => _tick(elapsed));
  }

  void dispose() => _active = false;
}
