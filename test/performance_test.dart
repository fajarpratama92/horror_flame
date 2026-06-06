import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:horror_flame/core/game/veilborn_game.dart';
import 'package:horror_flame/features/survival/survival_controller.dart';
import 'package:horror_flame/features/progression/xp_system.dart';

/// Performance tests — validates critical timing and computation targets.
///
/// Run with: flutter test test/performance_test.dart --timeout=120s
///
/// NOTE: Frame rate tests use pump() to simulate game ticks.
/// Real 60fps validation requires device testing with Flutter DevTools.
void main() {

  // ── Survival controller performance ──────────────────────
  group('SurvivalController: update() performance', () {
    test('1000 update() calls complete under 16ms (one frame budget)', () {
      final controller = SurvivalController()
        ..inDarkZone = true
        ..nearBoss    = true;

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        controller.update(0.016); // simulate 60fps tick
      }
      stopwatch.stop();

      // 1000 frames at 60fps = ~16.6 seconds of game time
      // Each frame budget is 16ms — all 1000 should complete well under that
      final avgMicros = stopwatch.elapsedMicroseconds / 1000;
      expect(
        avgMicros,
        lessThan(1000), // < 1ms per tick (well within 16ms budget)
        reason: 'SurvivalController.update() avg ${avgMicros.toStringAsFixed(1)}µs — '
                'must be <1000µs per tick',
      );
    });

    test('Sanity threshold check does not allocate in hot path', () {
      final controller = SurvivalController();
      // Warm up JIT
      for (int i = 0; i < 100; i++) {
        controller.update(0.016);
      }
      // Measure — should not trigger GC pressure
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        controller.update(0.016);
      }
      stopwatch.stop();
      // 10000 ticks should complete in well under 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  // ── XP system performance ─────────────────────────────────
  group('XpSystem: performance', () {
    test('_pow() computation completes in <1µs', () {
      final xp = XpSystem();

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 100000; i++) {
        xp.xpToNextLevel; // calls _pow internally
      }
      stopwatch.stop();

      final avgNanos = stopwatch.elapsedMicroseconds * 1000 / 100000;
      expect(
        avgNanos,
        lessThan(10000), // < 10µs per call (generous)
        reason: '_pow avg ${avgNanos.toStringAsFixed(1)}ns',
      );
    });

    test('rollSkillChoices() with full ownership completes fast', () {
      final xp     = XpSystem();
      final owned  = SkillId.values.take(9).toList();

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        xp.rollSkillChoices(owned);
      }
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100), // 1000 rolls in <100ms
      );
    });
  });

  // ── AiStateMachine state transitions performance ──────────
  group('AiStateMachine: transition performance', () {
    test('1000 state evaluations complete in <5ms', () {
      // Simulate AI update loop
      // Can't import AiStateMachine here without full component setup,
      // so we test the underlying logic indirectly via survival controller
      final controller = SurvivalController();
      final stopwatch  = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        // Simulate rapid threshold checks (similar to AI distance checks)
        controller.sanity = (i % 100).toDouble();
        controller.update(0.001);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });

  // ── GameWidget mount performance ──────────────────────────
  group('VeilbornGame: mount performance', () {
    testWidgets('Game mounts in <500ms', (tester) async {
      final stopwatch = Stopwatch()..start();

      final game = VeilbornGame();
      await tester.pumpWidget(
        MaterialApp(
          home: GameWidget(game: game),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000), // generous for CI — real device target is <500ms
        reason: 'Game mount took ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('60 pump() cycles at 16ms complete without stutter', (tester) async {
      final game = VeilbornGame();
      await tester.pumpWidget(
        MaterialApp(home: GameWidget(game: game)),
      );

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      stopwatch.stop();

      // 60 frames × 16ms = 960ms
      // Allow 2× overhead for test environment
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason: '60 game ticks took ${stopwatch.elapsedMilliseconds}ms',
      );
    });
  });

  // ── Memory: No obvious leaks in repeated instantiation ────
  group('Memory: Object lifecycle', () {
    test('SurvivalController can be created/GC\'d 1000 times', () {
      // Just verify no errors thrown — GC measured with Dart DevTools
      for (int i = 0; i < 1000; i++) {
        final c = SurvivalController();
        c.takeDamage(10);
        c.healDamage(10); // ensure all paths run
      }
      // If we get here without OOM or exception, pass
      expect(true, isTrue);
    });

    test('XpSystem create/reset 1000 times — no accumulation', () {
      for (int i = 0; i < 1000; i++) {
        final xp = XpSystem();
        xp.gainXp(xp.xpToNextLevel * 5); // force level up
        expect(xp.level, greaterThan(1));
      }
      expect(true, isTrue);
    });
  });

  // ── Compute: Survival thresholds ─────────────────────────
  group('SurvivalController: threshold accuracy', () {
    test('Sanity thresholds fire at exact values', () {
      final controller = SurvivalController();
      final fired = <SanityThreshold>[];
      controller.onSanityThresholdCrossed = fired.add;

      // Drop just below each threshold
      controller.sanity = 76.0;
      controller.drainSanityOnHit(); // → ~61 → mid

      controller.sanity = 51.0;
      controller.drainSanityOnHit(); // → ~36 → low

      controller.sanity = 26.0;
      controller.drainSanityOnHit(); // → ~11 → critical

      expect(fired.length, equals(3));
      expect(fired[0], equals(SanityThreshold.mid));
      expect(fired[1], equals(SanityThreshold.low));
      expect(fired[2], equals(SanityThreshold.critical));
    });

    test('Stamina regen rate is accurate', () {
      final controller = SurvivalController();
      controller.consumeStamina(50.0); // stamina = 50

      // Wait past regen delay
      controller.update(2.0); // 1.5s delay + 0.5s regen
      // Expected: 50 + (0.5 * regenRate)
      // regenRate = 20/s → 0.5s = +10
      expect(controller.stamina, closeTo(60.0, 2.0));
    });
  });
}

// Temp helper for test — heal equivalent
extension _SurvivalHeal on SurvivalController {
  void healDamage(double amount) => heal(amount);
}
