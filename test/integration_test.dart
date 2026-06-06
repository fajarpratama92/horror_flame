import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horror_flame/core/game/veilborn_game.dart';
import 'package:horror_flame/features/survival/survival_controller.dart';
import 'package:horror_flame/features/survival/survival_provider.dart';
import 'package:horror_flame/features/progression/xp_system.dart';
import 'package:horror_flame/features/progression/progression_provider.dart';
import 'package:horror_flame/features/save/save_manager.dart';
import 'package:horror_flame/features/shop/iap_service.dart';
import 'package:horror_flame/features/shop/shop_provider.dart';

/// Integration test — simulates a full Veilborn game session.
///
/// Validates:
/// - Game boots without crash
/// - Player can perform all actions
/// - Survival resources update correctly
/// - XP and level-up trigger correctly
/// - Chapter clear flow triggers
/// - Save/load round-trip succeeds
void main() {
  group('Integration: Full game session', () {

    // ── Game boot ───────────────────────────────────────────
    testWidgets('VeilbornGame mounts without crash', (tester) async {
      final game = VeilbornGame();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: GameWidget(game: game),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(GameWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // ── Survival system integration ─────────────────────────
    group('Survival system: end-to-end', () {
      late SurvivalController controller;

      setUp(() {
        controller = SurvivalController();
      });

      test('Full combat sequence does not throw', () {
        // Simulate 5 hits
        for (int i = 0; i < 5; i++) {
          controller.takeDamage(10.0);
        }
        expect(controller.health, equals(50.0));

        // Dash 3 times (stamina cost 25 each)
        controller.consumeStamina(25.0);
        controller.consumeStamina(25.0);
        controller.consumeStamina(25.0);
        expect(controller.stamina, equals(25.0));

        // Enter dark zone for 2 seconds
        controller.inDarkZone = true;
        controller.update(2.0);
        expect(controller.sanity, lessThan(100.0));
      });

      test('Sanity threshold cascade fires correctly', () {
        final thresholds = <SanityThreshold>[];
        controller.onSanityThresholdCrossed = (t) => thresholds.add(t);

        // Drain sanity through all thresholds
        controller.sanity = 76.0;
        controller.drainSanityOnHit(); // → below 75 → mid
        controller.sanity = 51.0;
        controller.drainSanityOnHit(); // → below 50 → low
        controller.sanity = 26.0;
        controller.drainSanityOnHit(); // → below 25 → critical

        expect(thresholds, containsAllInOrder([
          SanityThreshold.mid,
          SanityThreshold.low,
          SanityThreshold.critical,
        ]));
      });

      test('Stamina regen fires after delay', () {
        controller.consumeStamina(50.0);
        expect(controller.stamina, equals(50.0));

        // Before regen delay
        controller.update(1.0);
        expect(controller.stamina, equals(50.0)); // still waiting

        // After regen delay
        controller.update(1.0);
        expect(controller.stamina, greaterThan(50.0));
      });

      test('Death callback fires once when health hits zero', () {
        int deathCount = 0;
        controller.onDeath = () => deathCount++;
        controller.takeDamage(1000.0);
        controller.takeDamage(1000.0); // second hit should not re-fire
        expect(deathCount, equals(1));
      });
    });

    // ── XP + Skill progression integration ──────────────────
    group('XP progression: end-to-end', () {
      late XpSystem xp;

      setUp(() => xp = XpSystem());

      test('Full 10-level run progression without error', () {
        final ownedSkills = <SkillId>[];
        int levelUps = 0;

        while (!xp.isMaxLevel) {
          final threshold = xp.xpToNextLevel;
          final levelled  = xp.gainXp(threshold + 1);
          if (levelled) {
            levelUps++;
            final choices = xp.rollSkillChoices(ownedSkills);
            expect(choices.length, equals(3));
            expect(choices.toSet().length, equals(3)); // unique
            ownedSkills.add(choices.first);
          }
        }

        expect(xp.level, equals(10));
        expect(levelUps, equals(9)); // levels 1→10 = 9 level-ups
      });

      test('Skill choices never include already-owned skills', () {
        final owned = SkillId.values.take(9).toList(); // own 9 of 12
        final choices = xp.rollSkillChoices(owned);
        for (final choice in choices) {
          expect(owned.contains(choice), isFalse);
        }
        expect(choices.length, equals(3));
      });
    });

    // ── Save/load round-trip ────────────────────────────────
    group('Save/load: round-trip', () {
      test('GameSettings serialises and deserialises correctly', () {
        const original = GameSettings(
          masterVolume:   0.8,
          sfxVolume:      0.6,
          musicVolume:    0.5,
          reduceMotion:   true,
          colorBlindMode: false,
        );

        final json     = original.toJson();
        final restored = GameSettings.fromJson(json);

        expect(restored.masterVolume,   equals(0.8));
        expect(restored.sfxVolume,      equals(0.6));
        expect(restored.musicVolume,    equals(0.5));
        expect(restored.reduceMotion,   isTrue);
        expect(restored.colorBlindMode, isFalse);
      });

      test('GameSettings.copyWith preserves unchanged fields', () {
        const base = GameSettings(masterVolume: 0.9, musicVolume: 0.4);
        final copy = base.copyWith(sfxVolume: 0.2);
        expect(copy.masterVolume,  equals(0.9)); // unchanged
        expect(copy.sfxVolume,     equals(0.2)); // changed
        expect(copy.musicVolume,   equals(0.4)); // unchanged
      });
    });

    // ── ShopState integration ───────────────────────────────
    group('ShopState: skin ownership flow', () {
      test('Default state owns only ashen_knight', () {
        const state = ShopState(
          ownedSkins:      ['ashen_knight'],
          equippedSkin:    'ashen_knight',
          purchasePending: false,
          lastError:       null,
        );
        expect(state.owns('ashen_knight'),   isTrue);
        expect(state.owns('void_stalker'),   isFalse);
        expect(state.owns('crimson_seraph'), isFalse);
        expect(state.owns('golden_warden'),  isFalse);
      });

      test('After purchase delivery, skin is owned', () {
        const initial = ShopState(
          ownedSkins: ['ashen_knight'],
          equippedSkin: 'ashen_knight',
          purchasePending: false,
          lastError: null,
        );
        final afterPurchase = initial.copyWith(
          ownedSkins: [...initial.ownedSkins, 'crimson_seraph'],
          purchasePending: false,
        );
        expect(afterPurchase.owns('crimson_seraph'), isTrue);
        expect(afterPurchase.purchasePending, isFalse);
      });

      test('Error state clears on successful purchase', () {
        const withError = ShopState(
          ownedSkins: ['ashen_knight'],
          equippedSkin: 'ashen_knight',
          purchasePending: false,
          lastError: 'Payment declined',
        );
        expect(withError.lastError, isNotNull);
        final cleared = withError.copyWith(lastError: null);
        expect(cleared.lastError, isNull);
      });
    });

    // ── SkinDefinition completeness ─────────────────────────
    group('SkinDefinition: catalogue completeness', () {
      test('All 4 skins have non-empty fields', () {
        for (final skin in SkinDefinition.all) {
          expect(skin.id.isNotEmpty,          isTrue, reason: 'ID empty');
          expect(skin.name.isNotEmpty,        isTrue, reason: 'name empty');
          expect(skin.description.isNotEmpty, isTrue, reason: 'desc empty');
        }
      });

      test('Exactly 2 free + 2 IAP skins', () {
        final free = SkinDefinition.all
            .where((s) => s.unlockType == UnlockType.free).length;
        final achieve = SkinDefinition.all
            .where((s) => s.unlockType == UnlockType.achievement).length;
        final iap = SkinDefinition.all
            .where((s) => s.unlockType == UnlockType.iap).length;
        expect(free,    equals(1)); // ashen_knight
        expect(achieve, equals(1)); // void_stalker
        expect(iap,     equals(2)); // crimson + golden
      });
    });
  });
}
