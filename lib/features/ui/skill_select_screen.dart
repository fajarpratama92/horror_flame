import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../progression/xp_system.dart';
import '../progression/progression_provider.dart';

/// Skill select screen — shown after every level up.
///
/// Pauses the game loop. Displays 3 randomly rolled skill cards.
/// Player taps a card → skill applied → game resumes.
class SkillSelectScreen extends ConsumerStatefulWidget {
  const SkillSelectScreen({
    super.key,
    required this.choices,
    required this.onSkillSelected,
    required this.currentLevel,
  });

  final List<SkillId>   choices;
  final void Function(SkillId) onSkillSelected;
  final int             currentLevel;

  @override
  ConsumerState<SkillSelectScreen> createState() => _SkillSelectScreenState();
}

class _SkillSelectScreenState extends ConsumerState<SkillSelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double>   _fade;
  SkillId? _selected;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _selectSkill(SkillId id) {
    if (_selected != null) return; // prevent double-tap
    setState(() => _selected = id);
    _fadeCtrl.reverse().then((_) {
      widget.onSkillSelected(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withOpacity(0.88),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Header ──────────────────────────────────
              Text(
                'Level ${widget.currentLevel}',
                style: const TextStyle(
                  color: Color(0xFF6B3FA0),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .08,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a skill',
                style: TextStyle(
                  color: Color(0xFFE8E4FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your choice shapes this run',
                style: TextStyle(
                  color: Color(0xFF9A9AB0),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 32),

              // ── Skill cards ──────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.choices.map((id) {
                      final def = SkillDefinition.byId(id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SkillCard(
                          definition: def,
                          isSelected: _selected == id,
                          isDimmed: _selected != null && _selected != id,
                          onTap: () => _selectSkill(id),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Tap a card to continue',
                style: TextStyle(
                  color: Color(0xFF5F5E5A),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skill card widget ─────────────────────────────────────
class _SkillCard extends StatefulWidget {
  const _SkillCard({
    required this.definition,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  final SkillDefinition definition;
  final bool            isSelected;
  final bool            isDimmed;
  final VoidCallback    onTap;

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Color get _categoryColor => switch (widget.definition.category) {
    SkillCategory.combat   => const Color(0xFF8B1A1A),
    SkillCategory.survival => const Color(0xFF2A6B5C),
    SkillCategory.mobility => const Color(0xFF3C3489),
  };

  Color get _categoryBg => switch (widget.definition.category) {
    SkillCategory.combat   => const Color(0xFF1A0808),
    SkillCategory.survival => const Color(0xFF081A14),
    SkillCategory.mobility => const Color(0xFF0D0A1A),
  };

  String get _categoryLabel => switch (widget.definition.category) {
    SkillCategory.combat   => 'Combat',
    SkillCategory.survival => 'Survival',
    SkillCategory.mobility => 'Mobility',
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.isDimmed ? 0.35 : 1.0,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.reverse(),
        onTapUp: (_) {
          _pressCtrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.forward(),
        child: AnimatedBuilder(
          animation: _pressCtrl,
          builder: (context, child) => Transform.scale(
            scale: _pressCtrl.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isSelected ? _categoryBg : const Color(0xFF0D0A14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? _categoryColor
                    : const Color(0xFF3A3550),
                width: widget.isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                // Category icon blob
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _categoryColor.withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _skillIcon(widget.definition.id),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Skill info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.definition.name,
                              style: const TextStyle(
                                color: Color(0xFFE8E4FF),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _categoryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _categoryLabel,
                              style: TextStyle(
                                color: _categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.definition.description,
                        style: const TextStyle(
                          color: Color(0xFF9A9AB0),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _skillIcon(SkillId id) => switch (id) {
    SkillId.bloodEdge    => '⚔️',
    SkillId.voidStrike   => '💥',
    SkillId.soulDrain    => '🩸',
    SkillId.phantomBlade => '👻',
    SkillId.ironWill     => '🛡️',
    SkillId.secondWind   => '💨',
    SkillId.grounded     => '🌑',
    SkillId.resilience   => '✨',
    SkillId.shadowStep   => '🌫️',
    SkillId.wallrunner   => '🧗',
    SkillId.featherfall  => '🪶',
    SkillId.blink        => '⚡',
  };
}
