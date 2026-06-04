import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'xp_system.dart';

/// Riverpod provider bridging [XpSystem] game state to Flutter UI.
class ProgressionNotifier extends Notifier<ProgressionState> {
  late XpSystem _xp;
  final List<SkillId> _ownedSkills = [];

  @override
  ProgressionState build() {
    _xp = XpSystem();
    return ProgressionState.initial();
  }

  /// Called from game loop on XP gain.
  /// Returns [SkillSelectTrigger] if a level-up occurred.
  SkillSelectTrigger? gainXp(double amount) {
    final levelled = _xp.gainXp(amount);
    if (levelled) {
      final choices = _xp.rollSkillChoices(_ownedSkills);
      state = state.copyWith(
        level: _xp.level,
        xpProgress: _xp.xpProgress,
        pendingSkillChoices: choices,
        awaitingSkillSelect: true,
      );
      return SkillSelectTrigger(
        level:   _xp.level,
        choices: choices,
      );
    }
    state = state.copyWith(xpProgress: _xp.xpProgress);
    return null;
  }

  /// Called when player selects a skill from the screen.
  void applySkill(SkillId id) {
    _ownedSkills.add(id);
    state = state.copyWith(
      ownedSkills: List.from(_ownedSkills),
      awaitingSkillSelect: false,
      pendingSkillChoices: [],
    );
  }

  void resetRun() {
    _xp = XpSystem();
    _ownedSkills.clear();
    state = ProgressionState.initial();
  }
}

final progressionProvider =
    NotifierProvider<ProgressionNotifier, ProgressionState>(
        ProgressionNotifier.new);

// ── State model ───────────────────────────────────────────
class ProgressionState {
  const ProgressionState({
    required this.level,
    required this.xpProgress,
    required this.ownedSkills,
    required this.awaitingSkillSelect,
    required this.pendingSkillChoices,
  });

  factory ProgressionState.initial() => const ProgressionState(
    level:                1,
    xpProgress:           0.0,
    ownedSkills:          [],
    awaitingSkillSelect:  false,
    pendingSkillChoices:  [],
  );

  final int          level;
  final double       xpProgress;
  final List<SkillId> ownedSkills;
  final bool         awaitingSkillSelect;
  final List<SkillId> pendingSkillChoices;

  ProgressionState copyWith({
    int?           level,
    double?        xpProgress,
    List<SkillId>? ownedSkills,
    bool?          awaitingSkillSelect,
    List<SkillId>? pendingSkillChoices,
  }) => ProgressionState(
    level:               level               ?? this.level,
    xpProgress:          xpProgress          ?? this.xpProgress,
    ownedSkills:         ownedSkills         ?? this.ownedSkills,
    awaitingSkillSelect: awaitingSkillSelect ?? this.awaitingSkillSelect,
    pendingSkillChoices: pendingSkillChoices ?? this.pendingSkillChoices,
  );
}

class SkillSelectTrigger {
  const SkillSelectTrigger({required this.level, required this.choices});
  final int          level;
  final List<SkillId> choices;
}
