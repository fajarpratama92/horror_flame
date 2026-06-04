import 'package:flutter_test/flutter_test.dart';
import 'package:horror_flame/features/enemy/ai_state_machine.dart';
import 'package:horror_flame/features/progression/xp_system.dart';
import 'package:horror_flame/features/survival/survival_provider.dart';
import 'package:horror_flame/features/survival/survival_controller.dart';

void main() {

  // ── AI State Machine ──────────────────────────────────────
  group('AiStateMachine', () {
    late AiStateMachine ai;

    setUp(() {
      ai = AiStateMachine(
        detectionRange: 200,
        attackRange:    50,
        retreatHpRatio: 0.2,
      );
    });

    test('starts in patrol state', () {
      expect(ai.state, equals(EnemyAiState.patrol));
    });

    test('transitions to chase when player in detection range', () {
      ai.distanceToPlayer = 150;
      ai.update(0.016);
      expect(ai.state, equals(EnemyAiState.chase));
    });

    test('stays in patrol when player out of range', () {
      ai.distanceToPlayer = 300;
      ai.update(0.016);
      expect(ai.state, equals(EnemyAiState.patrol));
    });

    test('transitions to attack when player in attack range during chase', () {
      ai.distanceToPlayer = 150;
      ai.update(0.016); // → chase

      ai.distanceToPlayer = 30;
      ai.update(0.016); // → attack
      expect(ai.state, equals(EnemyAiState.attack));
    });

    test('transitions to retreat when HP low', () {
      ai.distanceToPlayer = 150;
      ai.update(0.016); // → chase

      ai.hpRatio = 0.1; // below retreat threshold
      ai.update(0.016);
      expect(ai.state, equals(EnemyAiState.retreat));
    });

    test('triggerDeath sets state to dead', () {
      ai.triggerDeath();
      expect(ai.state, equals(EnemyAiState.dead));
    });

    test('onPatrol callback is invoked in patrol state', () {
      bool called = false;
      ai.onPatrol = () => called = true;
      ai.update(0.016);
      expect(called, isTrue);
    });

    test('onChase callback is invoked in chase state', () {
      bool called = false;
      ai.onChase = () => called = true;
      ai.distanceToPlayer = 150;
      ai.update(0.016); // → chase
      ai.update(0.016); // execute chase
      expect(called, isTrue);
    });

    test('cooldown transitions back to chase', () {
      // Force into attack
      ai.distanceToPlayer = 30;
      ai.update(0.016); // patrol → chase
      ai.update(0.016); // chase → attack
      ai.update(0.016); // attack → cooldown

      // Simulate cooldown elapsed
      ai.distanceToPlayer = 30;
      for (int i = 0; i < 60; i++) ai.update(0.016); // ~1 second
      expect(ai.state, equals(EnemyAiState.chase));
    });
  });

  // ── SurvivalState ─────────────────────────────────────────
  group('SurvivalState', () {
    test('initial state has full resources', () {
      final state = SurvivalState.initial();
      expect(state.health,  equals(100));
      expect(state.stamina, equals(100));
      expect(state.sanity,  equals(100));
    });

    test('copyWith replaces only specified fields', () {
      final state  = SurvivalState.initial();
      final updated = state.copyWith(health: 42.0);
      expect(updated.health,  equals(42.0));
      expect(updated.stamina, equals(100));  // unchanged
      expect(updated.sanity,  equals(100));  // unchanged
    });

    test('copyWith currentThreshold', () {
      final state   = SurvivalState.initial();
      final updated = state.copyWith(
          currentThreshold: SanityThreshold.critical);
      expect(updated.currentThreshold, equals(SanityThreshold.critical));
    });
  });

  // ── SkillDefinition ───────────────────────────────────────
  group('SkillDefinition', () {
    test('all returns 12 skills', () {
      expect(SkillDefinition.all.length, equals(12));
    });

    test('byId returns correct skill', () {
      final skill = SkillDefinition.byId(SkillId.ironWill);
      expect(skill.name,     equals('Iron Will'));
      expect(skill.category, equals(SkillCategory.survival));
    });

    test('skills have unique IDs', () {
      final ids = SkillDefinition.all.map((s) => s.id).toSet();
      expect(ids.length, equals(SkillDefinition.all.length));
    });

    test('each category has 4 skills', () {
      for (final cat in SkillCategory.values) {
        final count = SkillDefinition.all
            .where((s) => s.category == cat).length;
        expect(count, equals(4),
            reason: '${cat.name} should have 4 skills');
      }
    });
  });
}
