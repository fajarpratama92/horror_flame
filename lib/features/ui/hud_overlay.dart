import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../survival/survival_controller.dart';
import '../survival/survival_provider.dart';

/// The in-game HUD rendered as a Flutter widget overlay on top of the
/// Flame GameWidget.
///
/// Contains:
/// - Health bar (red)
/// - Stamina bar (teal)
/// - Sanity bar (white → crimson as it depletes)
/// - Soul Essence counter
/// - Pause button
class HudOverlay extends ConsumerWidget {
  const HudOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final survival = ref.watch(survivalProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Survival bars ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SurvivalBar(
                        label: '♥',
                        value: survival.health,
                        max:   survival.maxHealth,
                        color: const Color(0xFF8B1A1A),
                        lowColor: const Color(0xFFCC2222),
                      ),
                      const SizedBox(height: 5),
                      _SurvivalBar(
                        label: '⚡',
                        value: survival.stamina,
                        max:   survival.maxStamina,
                        color: const Color(0xFF2A6B5C),
                        lowColor: const Color(0xFF2A6B5C),
                      ),
                      const SizedBox(height: 5),
                      _SanityBar(
                        value: survival.sanity,
                        max:   survival.maxSanity,
                        threshold: survival.currentThreshold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // ── Pause button ──────────────────────────
                GestureDetector(
                  onTap: () {
                    // TODO: call gameRef.pauseGame()
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF3A3550),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.pause,
                      color: Color(0xFFE8E4FF),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Survival bar widget ───────────────────────────────────
class _SurvivalBar extends StatelessWidget {
  const _SurvivalBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.lowColor,
  });

  final String label;
  final double value;
  final double max;
  final Color  color;
  final Color  lowColor;

  @override
  Widget build(BuildContext context) {
    final ratio = (value / max).clamp(0.0, 1.0);
    final isLow = ratio < 0.25;

    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFFE8E4FF)),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Fill
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 120),
                widthFactor: ratio,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: isLow ? lowColor : color,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: isLow
                        ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: Text(
            value.toInt().toString(),
            style: TextStyle(
              fontSize: 10,
              color: isLow
                  ? const Color(0xFFCC2222)
                  : const Color(0xFF9A9AB0),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sanity bar — special: colour shifts + pulsing at low ─────
class _SanityBar extends StatefulWidget {
  const _SanityBar({
    required this.value,
    required this.max,
    required this.threshold,
  });

  final double          value;
  final double          max;
  final SanityThreshold threshold;

  @override
  State<_SanityBar> createState() => _SanityBarState();
}

class _SanityBarState extends State<_SanityBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.7, end: 1.0).animate(_pulseCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _barColor() {
    switch (widget.threshold) {
      case SanityThreshold.normal:   return const Color(0xFFE8E4FF);
      case SanityThreshold.mid:      return const Color(0xFFB8B0E0);
      case SanityThreshold.low:      return const Color(0xFF8060C0);
      case SanityThreshold.critical: return const Color(0xFF8B1A1A);
      case SanityThreshold.zero:     return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio   = (widget.value / widget.max).clamp(0.0, 1.0);
    final isCrit  = widget.threshold == SanityThreshold.critical ||
                    widget.threshold == SanityThreshold.zero;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final opacity = isCrit ? _pulse.value : 1.0;
        return Opacity(
          opacity: opacity,
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                child: Text(
                  '☽',
                  style: TextStyle(fontSize: 11, color: Color(0xFFE8E4FF)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 200),
                      widthFactor: ratio,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: _barColor(),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isCrit
                              ? [BoxShadow(
                                  color: const Color(0xFF8B1A1A)
                                      .withOpacity(0.8),
                                  blurRadius: 8,
                                )]
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 36,
                child: Text(
                  widget.value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isCrit
                        ? const Color(0xFF8B1A1A)
                        : const Color(0xFF9A9AB0),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Soul Essence counter ──────────────────────────────────
class SoulEssenceCounter extends ConsumerWidget {
  const SoulEssenceCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: wire to soul essence provider
    const essence = 0;
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10, height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF6B3FA0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            '$essence',
            style: TextStyle(
              color: Color(0xFFE8E4FF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
