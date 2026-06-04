import '../../core/utils/constants.dart';

/// Manages XP gain, level-up logic, and skill selection for one run.
///
/// XP formula: threshold = 100 × (level ^ 1.4)
/// On level up: present 3 random skills from the available pool.
/// Progress does NOT carry between runs (fresh each run).
class XpSystem {
  int    level     = 1;
  double currentXp = 0.0;

  bool get isMaxLevel => level >= GameConstants.maxLevelPerRun;

  double get xpToNextLevel =>
      GameConstants.xpBaseThreshold * (_pow(level.toDouble(), GameConstants.xpLevelExponent));

  double get xpProgress => currentXp / xpToNextLevel;

  /// Called when player gains XP. Returns true if levelled up.
  bool gainXp(double amount) {
    if (isMaxLevel) return false;
    currentXp += amount;
    if (currentXp >= xpToNextLevel) {
      currentXp -= xpToNextLevel;
      level++;
      return true;
    }
    return false;
  }

  /// Returns 3 random skill IDs for the player to choose from.
  List<SkillId> rollSkillChoices(List<SkillId> alreadyOwned) {
    final available = SkillId.values
        .where((s) => !alreadyOwned.contains(s))
        .toList()
      ..shuffle();
    return available.take(GameConstants.skillChoiceCount).toList();
  }

  static double _pow(double base, double exp) {
    var result = 1.0;
    for (var i = 0; i < exp.floor(); i++) result *= base;
    return result;
  }
}

/// All 12 MVP skills.
enum SkillId {
  // Combat
  bloodEdge,
  voidStrike,
  soulDrain,
  phantomBlade,
  // Survival
  ironWill,
  secondWind,
  grounded,
  resilience,
  // Mobility
  shadowStep,
  wallrunner,
  featherfall,
  blink,
}

/// Skill metadata — name, description, category.
class SkillDefinition {
  const SkillDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  final SkillId id;
  final String  name;
  final String  description;
  final SkillCategory category;

  static const List<SkillDefinition> all = [
    // ── Combat ──────────────────────────────────────────────
    SkillDefinition(
      id: SkillId.bloodEdge,
      name: 'Blood Edge',
      description: 'Light attacks deal +5 damage.',
      category: SkillCategory.combat,
    ),
    SkillDefinition(
      id: SkillId.voidStrike,
      name: 'Void Strike',
      description: 'Heavy attacks knock enemies back 2× further.',
      category: SkillCategory.combat,
    ),
    SkillDefinition(
      id: SkillId.soulDrain,
      name: 'Soul Drain',
      description: 'Each kill restores 5 Health.',
      category: SkillCategory.combat,
    ),
    SkillDefinition(
      id: SkillId.phantomBlade,
      name: 'Phantom Blade',
      description: 'Dash-cancelling an attack adds 15 bonus damage.',
      category: SkillCategory.combat,
    ),
    // ── Survival ────────────────────────────────────────────
    SkillDefinition(
      id: SkillId.ironWill,
      name: 'Iron Will',
      description: 'Maximum Health +25.',
      category: SkillCategory.survival,
    ),
    SkillDefinition(
      id: SkillId.secondWind,
      name: 'Second Wind',
      description: 'Stamina regeneration rate +50%%.',
      category: SkillCategory.survival,
    ),
    SkillDefinition(
      id: SkillId.grounded,
      name: 'Grounded',
      description: 'Sanity drain rate −30%% in dark zones.',
      category: SkillCategory.survival,
    ),
    SkillDefinition(
      id: SkillId.resilience,
      name: 'Resilience',
      description: 'I-frame duration +0.3 seconds after taking damage.',
      category: SkillCategory.survival,
    ),
    // ── Mobility ────────────────────────────────────────────
    SkillDefinition(
      id: SkillId.shadowStep,
      name: 'Shadow Step',
      description: 'Dash distance +50%%.',
      category: SkillCategory.mobility,
    ),
    SkillDefinition(
      id: SkillId.wallrunner,
      name: 'Wallrunner',
      description: 'Wall-jump height +40%%.',
      category: SkillCategory.mobility,
    ),
    SkillDefinition(
      id: SkillId.featherfall,
      name: 'Featherfall',
      description: 'Eliminate all fall damage.',
      category: SkillCategory.mobility,
    ),
    SkillDefinition(
      id: SkillId.blink,
      name: 'Blink',
      description: 'Dash passes through enemies (no collision during dash).',
      category: SkillCategory.mobility,
    ),
  ];

  static SkillDefinition byId(SkillId id) =>
      all.firstWhere((s) => s.id == id);
}

enum SkillCategory { combat, survival, mobility }
