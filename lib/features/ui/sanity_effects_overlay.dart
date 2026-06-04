import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../survival/survival_controller.dart';
import '../survival/survival_provider.dart';

/// Fullscreen overlay that renders Sanity visual distortion effects.
///
/// Mounted as a GameWidget overlay on top of everything.
/// Reads SanityThreshold from Riverpod and applies:
///   - Vignette (mid+)
///   - Chromatic aberration hint (low+)
///   - Pulsing edge corruption (critical)
///   - Screen flicker and inversion (zero)
///
/// Honours the reduceMotion accessibility setting.
class SanityEffectsOverlay extends ConsumerStatefulWidget {
  const SanityEffectsOverlay({super.key, this.reduceMotion = false});

  final bool reduceMotion;

  @override
  ConsumerState<SanityEffectsOverlay> createState() =>
      _SanityEffectsOverlayState();
}

class _SanityEffectsOverlayState
    extends ConsumerState<SanityEffectsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _flickerCtrl;
  late Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _flickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _pulse = CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _flickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final survival  = ref.watch(survivalProvider);
    final threshold = survival.currentThreshold;

    if (threshold == SanityThreshold.normal) {
      return const SizedBox.shrink(); // No effect
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _flickerCtrl]),
      builder: (context, _) {
        return Stack(
          children: [
            // ── Vignette (mid+) ──────────────────────────
            if (threshold.index >= SanityThreshold.mid.index)
              _Vignette(
                intensity: _vignetteIntensity(threshold, _pulse.value),
                reduceMotion: widget.reduceMotion,
              ),

            // ── Edge corruption (low+) ───────────────────
            if (!widget.reduceMotion &&
                threshold.index >= SanityThreshold.low.index)
              _EdgeCorruption(
                phase: _pulseCtrl.value,
                intensity: _corruptionIntensity(threshold),
              ),

            // ── Critical overlay (critical+) ─────────────
            if (threshold.index >= SanityThreshold.critical.index)
              _CriticalOverlay(
                pulse: _pulse.value,
                reduceMotion: widget.reduceMotion,
              ),
          ],
        );
      },
    );
  }

  double _vignetteIntensity(SanityThreshold t, double pulse) {
    final base = switch (t) {
      SanityThreshold.mid      => 0.25,
      SanityThreshold.low      => 0.45,
      SanityThreshold.critical => 0.65,
      SanityThreshold.zero     => 0.85,
      SanityThreshold.normal   => 0.0,
    };
    return widget.reduceMotion ? base : base + (pulse * 0.08);
  }

  double _corruptionIntensity(SanityThreshold t) => switch (t) {
    SanityThreshold.low      => 0.3,
    SanityThreshold.critical => 0.7,
    SanityThreshold.zero     => 1.0,
    _                        => 0.0,
  };
}

// ── Vignette ──────────────────────────────────────────────
class _Vignette extends StatelessWidget {
  const _Vignette({required this.intensity, required this.reduceMotion});

  final double intensity;
  final bool   reduceMotion;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Color.fromRGBO(13, 10, 20, intensity * 0.6),
              Color.fromRGBO(13, 10, 20, intensity),
            ],
            stops: const [0.0, 0.45, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

// ── Edge corruption painter ───────────────────────────────
class _EdgeCorruption extends StatelessWidget {
  const _EdgeCorruption({required this.phase, required this.intensity});

  final double phase;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CorruptionPainter(phase: phase, intensity: intensity),
        size: Size.infinite,
      ),
    );
  }
}

class _CorruptionPainter extends CustomPainter {
  _CorruptionPainter({required this.phase, required this.intensity});

  final double phase;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng   = math.Random(42); // seeded — deterministic glitch shapes
    final paint = Paint()
      ..color = const Color(0xFF6B3FA0).withOpacity(intensity * 0.35)
      ..style = PaintingStyle.fill;

    // Scatter glitch rectangles around the edges
    for (int i = 0; i < 12; i++) {
      final t      = (phase + i * 0.08) % 1.0;
      final w      = rng.nextDouble() * 80 * intensity;
      final h      = rng.nextDouble() * 6  * intensity;
      final edge   = rng.nextInt(4);
      double x, y;

      switch (edge) {
        case 0: x = rng.nextDouble() * size.width;  y = 0;                        // top
        case 1: x = rng.nextDouble() * size.width;  y = size.height - h;          // bottom
        case 2: x = 0;                              y = rng.nextDouble() * size.height; // left
        default: x = size.width - w;                y = rng.nextDouble() * size.height; // right
      }

      canvas.drawRect(
        Rect.fromLTWH(x, y, w, h),
        paint..color = paint.color.withOpacity(intensity * 0.35 * t),
      );
    }
  }

  @override
  bool shouldRepaint(_CorruptionPainter old) =>
      old.phase != phase || old.intensity != intensity;
}

// ── Critical overlay ──────────────────────────────────────
class _CriticalOverlay extends StatelessWidget {
  const _CriticalOverlay({
    required this.pulse,
    required this.reduceMotion,
  });

  final double pulse;
  final bool   reduceMotion;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Color.fromRGBO(
          139, 26, 26,
          reduceMotion ? 0.08 : 0.08 + (pulse * 0.06),
        ),
      ),
    );
  }
}
