import 'package:flutter/material.dart';

/// Game Over screen — shown when player dies.
///
/// Displays run statistics, XP earned, and options to retry or return to menu.
/// Atmospheric fade-in, desaturated palette, slow animation.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.stats,
    required this.onRetry,
    required this.onMainMenu,
  });

  final RunStats      stats;
  final VoidCallback  onRetry;
  final VoidCallback  onMainMenu;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: const Color(0xDD0D0A14),
        child: SafeArea(
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                const Spacer(),

                // ── Death title ──────────────────────────
                const Text(
                  'YOU DIED',
                  style: TextStyle(
                    color: Color(0xFF8B1A1A),
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    letterSpacing: .25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chapter ${widget.stats.chapterReached} · ${_formatTime(widget.stats.survivalTimeSeconds)}',
                  style: const TextStyle(
                    color: Color(0xFF5F5E5A),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Run stats ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12101A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3A3550),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _StatRow(label: 'Enemies slain',     value: '${widget.stats.enemiesKilled}'),
                        _StatRow(label: 'Soul Essence',      value: '${widget.stats.soulEssenceCollected}'),
                        _StatRow(label: 'Level reached',     value: '${widget.stats.levelReached}'),
                        _StatRow(label: 'Skills acquired',   value: '${widget.stats.skillsAcquired}'),
                        _StatRow(label: 'Lowest sanity',     value: '${widget.stats.lowestSanity.toInt()}%', isLast: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── XP earned ────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B3FA0).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6B3FA0).withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⬡ ', style: TextStyle(fontSize: 14)),
                      Text(
                        '+${widget.stats.xpEarned} XP',
                        style: const TextStyle(
                          color: Color(0xFFAFA9EC),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Action buttons ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _GameOverButton(
                        label: 'Try Again',
                        icon: Icons.refresh_rounded,
                        isPrimary: true,
                        onTap: widget.onRetry,
                      ),
                      const SizedBox(height: 10),
                      _GameOverButton(
                        label: 'Main Menu',
                        icon: Icons.home_outlined,
                        isPrimary: false,
                        onTap: widget.onMainMenu,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat row ──────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool   isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(label, style: const TextStyle(
                color: Color(0xFF5F5E5A), fontSize: 13)),
              const Spacer(),
              Text(value, style: const TextStyle(
                color: Color(0xFFE8E4FF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFeatures: [FontFeature.tabularFigures()],
              )),
            ],
          ),
        ),
        if (!isLast)
          const Divider(color: Color(0xFF2A2535), height: 1, thickness: 0.5),
      ],
    );
  }
}

// ── Button ────────────────────────────────────────────────
class _GameOverButton extends StatelessWidget {
  const _GameOverButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String       label;
  final IconData     icon;
  final bool         isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF6B3FA0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFF6B3FA0)
                : const Color(0xFF3A3550),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16,
                color: isPrimary
                    ? const Color(0xFFE8E4FF)
                    : const Color(0xFF9A9AB0)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? const Color(0xFFE8E4FF)
                    : const Color(0xFF9A9AB0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Run stats model ───────────────────────────────────────
class RunStats {
  const RunStats({
    required this.enemiesKilled,
    required this.soulEssenceCollected,
    required this.levelReached,
    required this.skillsAcquired,
    required this.lowestSanity,
    required this.survivalTimeSeconds,
    required this.chapterReached,
    required this.xpEarned,
  });

  final int    enemiesKilled;
  final int    soulEssenceCollected;
  final int    levelReached;
  final int    skillsAcquired;
  final double lowestSanity;
  final int    survivalTimeSeconds;
  final int    chapterReached;
  final int    xpEarned;

  factory RunStats.empty() => const RunStats(
    enemiesKilled: 0,
    soulEssenceCollected: 0,
    levelReached: 1,
    skillsAcquired: 0,
    lowestSanity: 100,
    survivalTimeSeconds: 0,
    chapterReached: 1,
    xpEarned: 0,
  );
}
