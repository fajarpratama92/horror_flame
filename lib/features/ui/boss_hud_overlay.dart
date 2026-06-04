import 'package:flutter/material.dart';

/// Boss HUD — displayed at bottom of screen during boss encounters.
///
/// Shows boss name, phase indicator, and animated health bar.
/// Appears with a slide-up animation when the boss room is entered.
class BossHudOverlay extends StatefulWidget {
  const BossHudOverlay({
    super.key,
    required this.bossName,
    required this.bossHealth,
    required this.bossMaxHealth,
    required this.currentPhase,
    required this.totalPhases,
  });

  final String bossName;
  final double bossHealth;
  final double bossMaxHealth;
  final int    currentPhase;
  final int    totalPhases;

  @override
  State<BossHudOverlay> createState() => _BossHudOverlayState();
}

class _BossHudOverlayState extends State<BossHudOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() { _slideCtrl.dispose(); super.dispose(); }

  Color get _phaseColor => switch (widget.currentPhase) {
    1 => const Color(0xFF888780),
    2 => const Color(0xFFEF9F27),
    _ => const Color(0xFF8B1A1A),
  };

  double get _hpRatio =>
      (widget.bossHealth / widget.bossMaxHealth).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xEE0D0A14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _phaseColor.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Boss name + phase dots ───────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.bossName,
                      style: TextStyle(
                        color: _phaseColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .04,
                      ),
                    ),
                  ),
                  // Phase indicators
                  Row(
                    children: List.generate(widget.totalPhases, (i) {
                      final active = i < widget.currentPhase;
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? _phaseColor
                              : const Color(0xFF3A3550),
                          border: Border.all(
                            color: _phaseColor.withOpacity(0.4),
                            width: 0.5,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Health bar ───────────────────────────────
              Stack(
                children: [
                  // Track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1626),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Fill
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 180),
                    widthFactor: _hpRatio,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: _phaseColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: _phaseColor.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Phase threshold lines
                  if (widget.totalPhases > 1)
                    ...List.generate(widget.totalPhases - 1, (i) {
                      final fraction = (i + 1) / widget.totalPhases;
                      return FractionallySizedBox(
                        widthFactor: fraction,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 1.5,
                            height: 8,
                            color: const Color(0xFF0D0A14),
                          ),
                        ),
                      );
                    }),
                ],
              ),

              const SizedBox(height: 4),

              // ── HP numbers ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.currentPhase < widget.totalPhases
                        ? 'Phase ${widget.currentPhase}'
                        : 'Final Phase',
                    style: TextStyle(
                      color: _phaseColor.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${widget.bossHealth.toInt()} / ${widget.bossMaxHealth.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF5F5E5A),
                      fontSize: 10,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
