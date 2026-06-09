import 'package:flutter_test/flutter_test.dart';
import 'package:horror_flame/features/survival/survival_controller.dart';
import 'package:horror_flame/features/progression/xp_system.dart';
import 'package:horror_flame/features/save/save_manager.dart';
import 'package:horror_flame/features/shop/iap_service.dart';
import 'package:horror_flame/features/shop/shop_provider.dart';

/// Integration test — full game session (pure unit, no widget/Flame rendering).
///
/// Widget-based Flame tests require a device/simulator with a native surface
/// and are excluded from CI. Run them with: flutter test --device-id=<device>
void main() {

  // ── Survival system integration ─────────────────────────────
  group('Survival system: end-to-end', () {
    late SurvivalController controller;
    setUp(() => controller = SurvivalController());

    test('Full combat sequence completes without error', () {
      for (int i = 0; i < 5; i++) controller.takeDamage(10.0);
      expect(controller.health, equals(50.0));
      controller.consumeStamina(25.0);
      controller.consumeStamina(25.0);
      controller.consumeStamina(25.0);
      expect(controller.stamina, equals(25.0));
      controller.inDarkZone = true;
      controller.update(2.0);
      expect(controller.sanity, lessThan(100.0));
    });

    test('Sanity threshold cascade fires in correct order', () {
      final thresholds = <SanityThreshold>[];
      controller.onSanityThresholdCrossed = thresholds.add;
      controller.sanity = 76.0;
      controller.drainSanityOnHit();
      controller.sanity = 51.0;
      controller.drainSanityOnHit();
      controller.sanity = 26.0;
      controller.drainSanityOnHit();
      expect(thresholds, containsAllInOrder([
        SanityThreshold.mid,
        SanityThreshold.low,
        SanityThreshold.critical,
      ]));
    });

    test('Stamina regens after delay', () {
      controller.consumeStamina(50.0);
      controller.update(1.0);
      expect(controller.stamina, equals(50.0));
      controller.update(1.0);
      expect(controller.stamina, greaterThan(50.0));
    });

    test('Death fires once only', () {
      int deaths = 0;
      controller.onDeath = () => deaths++;
      controller.takeDamage(1000.0);
      controller.takeDamage(1000.0);
      expect(deaths, equals(1));
    });
  });

  // ── XP + progression integration ───────────────────────────
  group('XP progression: end-to-end', () {
    late XpSystem xp;
    setUp(() => xp = XpSystem());

    test('Full 10-level run without error', () {
      final owned = <SkillId>[];
      int levelUps = 0;
      while (!xp.isMaxLevel) {
        if (xp.gainXp(xp.xpToNextLevel + 1)) {
          levelUps++;
          final choices = xp.rollSkillChoices(owned);
          expect(choices.length, equals(3));
          expect(choices.toSet().length, equals(3));
          owned.add(choices.first);
        }
      }
      expect(xp.level, equals(10));
      expect(levelUps, equals(9));
    });

    test('Skill choices never include owned skills', () {
      final owned = SkillId.values.take(9).toList();
      final choices = xp.rollSkillChoices(owned);
      for (final c in choices) expect(owned.contains(c), isFalse);
      expect(choices.length, equals(3));
    });
  });

  // ── Save/load round-trip ────────────────────────────────────
  group('Save/load: round-trip', () {
    test('GameSettings serialises and deserialises', () {
      const orig = GameSettings(
        masterVolume: 0.8, sfxVolume: 0.6, musicVolume: 0.5,
        reduceMotion: true, colorBlindMode: false,
      );
      final restored = GameSettings.fromJson(orig.toJson());
      expect(restored.masterVolume,   equals(0.8));
      expect(restored.sfxVolume,      equals(0.6));
      expect(restored.musicVolume,    equals(0.5));
      expect(restored.reduceMotion,   isTrue);
      expect(restored.colorBlindMode, isFalse);
    });

    test('GameSettings.copyWith preserves unchanged fields', () {
      const base = GameSettings(masterVolume: 0.9, musicVolume: 0.4);
      final copy = base.copyWith(sfxVolume: 0.2);
      expect(copy.masterVolume, equals(0.9));
      expect(copy.sfxVolume,    equals(0.2));
      expect(copy.musicVolume,  equals(0.4));
    });
  });

  // ── ShopState integration ───────────────────────────────────
  group('ShopState: skin ownership', () {
    test('Default owns only ashen_knight', () {
      const state = ShopState(
        ownedSkins: ['ashen_knight'], equippedSkin: 'ashen_knight',
        purchasePending: false, lastError: null,
      );
      expect(state.owns('ashen_knight'),   isTrue);
      expect(state.owns('crimson_seraph'), isFalse);
    });

    test('After delivery skin is owned', () {
      const s = ShopState(
        ownedSkins: ['ashen_knight'], equippedSkin: 'ashen_knight',
        purchasePending: false, lastError: null,
      );
      final after = s.copyWith(
        ownedSkins: [...s.ownedSkins, 'crimson_seraph'],
        purchasePending: false,
      );
      expect(after.owns('crimson_seraph'), isTrue);
    });
  });

  // ── SkinDefinition completeness ─────────────────────────────
  group('SkinDefinition: catalogue', () {
    test('All 4 skins have non-empty fields', () {
      for (final skin in SkinDefinition.all) {
        expect(skin.id.isNotEmpty,          isTrue);
        expect(skin.name.isNotEmpty,        isTrue);
        expect(skin.description.isNotEmpty, isTrue);
      }
    });

    test('Correct unlock type distribution', () {
      expect(SkinDefinition.all
        .where((s) => s.unlockType == UnlockType.free).length, equals(1));
      expect(SkinDefinition.all
        .where((s) => s.unlockType == UnlockType.achievement).length, equals(1));
      expect(SkinDefinition.all
        .where((s) => s.unlockType == UnlockType.iap).length, equals(2));
    });
  });
}
