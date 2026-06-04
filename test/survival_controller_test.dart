import 'package:flutter_test/flutter_test.dart';
import 'package:horror_flame/features/survival/survival_controller.dart';
import 'package:horror_flame/core/utils/constants.dart';

void main() {
  group('SurvivalController', () {
    late SurvivalController controller;

    setUp(() {
      controller = SurvivalController();
    });

    // ── Health ───────────────────────────────────────────────
    group('Health', () {
      test('starts at max health', () {
        expect(controller.health, equals(GameConstants.playerBaseHealth));
      });

      test('takeDamage reduces health', () {
        controller.takeDamage(25.0);
        expect(controller.health, equals(75.0));
      });

      test('health does not go below zero', () {
        controller.takeDamage(9999.0);
        expect(controller.health, equals(0.0));
      });

      test('heal restores health', () {
        controller.takeDamage(50.0);
        controller.heal(30.0);
        expect(controller.health, equals(80.0));
      });

      test('heal does not exceed max health', () {
        controller.heal(9999.0);
        expect(controller.health, equals(controller.maxHealth));
      });

      test('onDeath called when health reaches zero', () {
        bool deathCalled = false;
        controller.onDeath = () => deathCalled = true;
        controller.takeDamage(9999.0);
        expect(deathCalled, isTrue);
      });
    });

    // ── Stamina ──────────────────────────────────────────────
    group('Stamina', () {
      test('starts at max stamina', () {
        expect(controller.stamina, equals(GameConstants.playerBaseStamina));
      });

      test('consumeStamina returns false when insufficient', () {
        controller.stamina = 10.0;
        expect(controller.consumeStamina(25.0), isFalse);
        expect(controller.stamina, equals(10.0)); // unchanged
      });

      test('consumeStamina returns true and deducts when sufficient', () {
        expect(controller.consumeStamina(25.0), isTrue);
        expect(controller.stamina, equals(75.0));
      });

      test('canDash is false when stamina < dash cost', () {
        controller.stamina = 20.0;
        expect(controller.canDash, isFalse);
      });

      test('canDash is true when stamina >= dash cost', () {
        expect(controller.canDash, isTrue);
      });
    });

    // ── Sanity ───────────────────────────────────────────────
    group('Sanity', () {
      test('starts at max sanity', () {
        expect(controller.sanity, equals(GameConstants.playerBaseSanity));
      });

      test('sanity threshold: normal at 100', () {
        SanityThreshold? crossed;
        controller.onSanityThresholdCrossed = (t) => crossed = t;
        controller.restoreSanity(0); // trigger check with no change
        expect(crossed, isNull); // no threshold crossed
      });

      test('drainSanityOnHit reduces sanity by correct amount', () {
        controller.drainSanityOnHit();
        expect(controller.sanity,
            equals(GameConstants.playerBaseSanity - GameConstants.sanityDrainOnHit));
      });

      test('sanity threshold mid fires at 74', () {
        SanityThreshold? crossed;
        controller.onSanityThresholdCrossed = (t) => crossed = t;
        controller.sanity = 75.0;
        controller.drainSanityOnHit(); // drops to 60 → mid threshold
        expect(crossed, equals(SanityThreshold.mid));
      });

      test('run fails on second sanity zero', () {
        int deathCount = 0;
        controller.onDeath = () => deathCount++;

        // Force sanity to 0 twice
        controller.sanity = 1.0;
        controller.drainSanityOnHit(); // → 0 (first zero)
        controller.sanity = 1.0;
        controller.drainSanityOnHit(); // → 0 (second zero → death)

        expect(deathCount, equals(1));
      });

      test('restoreSanity does not exceed max', () {
        controller.restoreSanity(9999.0);
        expect(controller.sanity, equals(controller.maxSanity));
      });
    });

    // ── Upgrade hooks ────────────────────────────────────────
    group('Upgrades', () {
      test('upgradeMaxHealth increases max and current health', () {
        controller.upgradeMaxHealth(25.0);
        expect(controller.maxHealth, equals(125.0));
      });

      test('upgradeMaxStamina increases max stamina', () {
        controller.upgradeMaxStamina(30.0);
        expect(controller.maxStamina, equals(130.0));
      });
    });
  });
}
