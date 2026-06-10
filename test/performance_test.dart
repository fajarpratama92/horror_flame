import 'package:flutter_test/flutter_test.dart';
import 'package:horror_flame/features/survival/survival_controller.dart';
import 'package:horror_flame/features/progression/xp_system.dart';
import 'package:horror_flame/features/enemy/ai_state_machine.dart';

/// Performance tests — validates computation timing targets.
///
/// All tests are pure unit tests (no widget/Flame rendering).
/// Flame GameWidget tests require a device with native surface:
///   flutter test test/performance_test.dart --device-id=<device>
void main() {

  // ── SurvivalController performance ────────────────────────
  group('SurvivalController: update() timing', () {
    test('1000 update() calls complete under 1 second', () {
      final controller = SurvivalController()
        ..inDarkZone = true
        ..nearBoss    = true;
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        controller.update(0.016);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(1000),
          reason: '1000 ticks took ${sw.elapsedMilliseconds}ms — must be <1000ms');
    });

    test('10000 update() calls stay under 5 seconds', () {
      final controller = SurvivalController();
      final sw = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        controller.update(0.016);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(5000));
    });
  });

  // ── XpSystem performance ───────────────────────────────────
  group('XpSystem: computation timing', () {
    test('100000 xpToNextLevel calls complete under 1 second', () {
      final xp = XpSystem();
      final sw = Stopwatch()..start();
      for (int i = 0; i < 100000; i++) {
        // ignore: unnecessary_statements
        xp.xpToNextLevel;
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(1000));
    });

    test('1000 rollSkillChoices calls complete under 100ms', () {
      final xp    = XpSystem();
      final owned = SkillId.values.take(9).toList();
      final sw    = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        xp.rollSkillChoices(owned);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(100));
    });
  });

  // ── AiStateMachine transitions performance ─────────────────
  group('AiStateMachine: state transitions', () {
    test('1000 AI state evaluations complete under 100ms', () {
      final ai = AiStateMachine(
        detectionRange: 200.0,
        attackRange:    50.0,
        retreatHpRatio: 0.2,
      );
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        ai.distanceToPlayer = (i % 300).toDouble();
        ai.hpRatio          = 0.5;
        ai.update(0.016);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(100));
    });
  });

  // ── Memory: repeated instantiation ────────────────────────
  group('Memory: object lifecycle', () {
    test('SurvivalController: 1000 create+use cycles without error', () {
      for (int i = 0; i < 1000; i++) {
        final c = SurvivalController();
        c.takeDamage(10.0);
        c.heal(10.0);
      }
      expect(true, isTrue); // Completed without OOM or exception
    });

    test('XpSystem: 1000 create+reset cycles without accumulation', () {
      for (int i = 0; i < 1000; i++) {
        final xp = XpSystem();
        xp.gainXp(xp.xpToNextLevel * 5.0);
        expect(xp.level, greaterThan(1));
      }
    });
  });

  // ── Sanity threshold accuracy ──────────────────────────────
  group('SurvivalController: threshold accuracy', () {
    test('Thresholds fire at exact boundary values', () {
      final c = SurvivalController();
      final fired = <SanityThreshold>[];
      c.onSanityThresholdCrossed = fired.add;
      c.sanity = 76.0; c.drainSanityOnHit(); // → mid
      c.sanity = 51.0; c.drainSanityOnHit(); // → low
      c.sanity = 26.0; c.drainSanityOnHit(); // → critical
      expect(fired, equals([
        SanityThreshold.mid,
        SanityThreshold.low,
        SanityThreshold.critical,
      ]));
    });

    test('Stamina regen rate is accurate within tolerance', () {
      final c = SurvivalController();
      c.consumeStamina(50.0); // stamina = 50
      c.update(2.0);          // 2s total > 1.5s delay; regen for 0.5s
      expect(c.stamina, closeTo(60.0, 2.0));
    });
  });
}
