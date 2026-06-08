import 'package:flutter/material.dart';
import 'game_over_screen.dart';

/// Chapter Clear screen — shown after defeating a chapter boss.
///
/// Celebrates the chapter completion, shows rewards earned,
/// and routes player to the next chapter or main menu.
class ChapterClearScreen extends StatefulWidget {
  const ChapterClearScreen({
    super.key,
    required this.chapter,
    required this.bossName,
    required this.stats,
    required this.skillEarned,
    required this.onContinue,
    required this.onMainMenu,
    this.isLastChapter = false,
  });

  final int          chapter;
  final String       bossName;
  final RunStats     stats;
  final String?      skillEarned;
  final VoidCallback onContinue;
  final VoidCallback onMainMenu;
  final bool         isLastChapter;

  @override
  State<ChapterClearScreen> createState() => _ChapterClearScreenState();
}

class _ChapterClearScreenState extends State<ChapterClearScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _contentCtrl;
  late AnimationController _rewardCtrl;
  late Animation<double>   _bgFade;
  late Animation<double>   _contentSlide;
  late Animation<double>   _rewardPop;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rewardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeIn);
    _contentSlide = CurvedAnimation(
        parent: _contentCtrl, curve: Curves.easeOutCubic);
    _rewardPop = CurvedAnimation(parent: _rewardCtrl, curve: Curves.elasticOut);

    // Staggered entrance
    Future.delayed(const Duration(milliseconds: 400), () {
      _contentCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      _rewardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _contentCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _bgFade,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xEE0D0A14),
              Color(0xEE12101A),
              Color(0xEE0D0A14),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Chapter cleared badge ────────────────────
              AnimatedBuilder(
                animation: _contentSlide,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, 20 * (1 - _contentSlide.value)),
                  child: Opacity(opacity: _contentSlide.value, child: child),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A6B5C).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2A6B5C).withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'Chapter ${widget.chapter} Complete',
                        style: const TextStyle(
                          color: Color(0xFF4DB89F),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: .06,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.bossName,
                      style: const TextStyle(
                        color: Color(0xFFE8E4FF),
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        letterSpacing: .1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'defeated',
                      style: TextStyle(
                        color: Color(0xFF5F5E5A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Stats ────────────────────────────────────
              AnimatedBuilder(
                animation: _contentSlide,
                builder: (context, child) => Opacity(
                  opacity: _contentSlide.value,
                  child: child,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MiniStat(
                          icon: '⚔️',
                          value: '${widget.stats.enemiesKilled}',
                          label: 'Slain'),
                      _MiniStat(
                          icon: '⏱',
                          value: _formatTime(widget.stats.survivalTimeSeconds),
                          label: 'Time'),
                      _MiniStat(
                          icon: '⬡',
                          value: '${widget.stats.soulEssenceCollected}',
                          label: 'Essence'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Rewards ──────────────────────────────────
              AnimatedBuilder(
                animation: _rewardPop,
                builder: (context, child) => Transform.scale(
                  scale: 0.85 + (0.15 * _rewardPop.value),
                  child: Opacity(
                    opacity: _rewardPop.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REWARDS',
                        style: TextStyle(
                          color: Color(0xFF5F5E5A),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: .08,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RewardRow(
                        icon: '⬡',
                        label: '+100 Soul Essence',
                        color: const Color(0xFF6B3FA0),
                      ),
                      const SizedBox(height: 8),
                      _RewardRow(
                        icon: '☽',
                        label: 'Sanity restored +20',
                        color: const Color(0xFFE8E4FF),
                      ),
                      if (widget.skillEarned != null) ...[
                        const SizedBox(height: 8),
                        _RewardRow(
                          icon: '✦',
                          label: widget.skillEarned!,
                          color: const Color(0xFF4DB89F),
                        ),
                      ],
                      if (widget.chapter == 1) ...[
                        const SizedBox(height: 8),
                        _RewardRow(
                          icon: '🎭',
                          label: 'Void Stalker skin unlocked',
                          color: const Color(0xFFAFA9EC),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ── Action buttons ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    if (!widget.isLastChapter)
                      _ClearButton(
                        label: 'Continue to Chapter ${widget.chapter + 1}',
                        isPrimary: true,
                        onTap: widget.onContinue,
                      ),
                    if (widget.isLastChapter)
                      _ClearButton(
                        label: 'Victory — Play Again',
                        isPrimary: true,
                        onTap: widget.onContinue,
                      ),
                    const SizedBox(height: 10),
                    _ClearButton(
                      label: 'Main Menu',
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
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final String icon, value, label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(
        color: Color(0xFFE8E4FF), fontSize: 14, fontWeight: FontWeight.w500)),
      Text(label, style: const TextStyle(
        color: Color(0xFF5F5E5A), fontSize: 11)),
    ],
  );
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.icon,
    required this.label,
    required this.color,
  });
  final String icon, label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(icon, style: TextStyle(fontSize: 14, color: color)),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(
        color: color, fontSize: 13, fontWeight: FontWeight.w500)),
    ],
  );
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });
  final String       label;
  final bool         isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF6B3FA0) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF6B3FA0)
              : const Color(0xFF3A3550),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isPrimary
              ? const Color(0xFFE8E4FF)
              : const Color(0xFF9A9AB0),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
