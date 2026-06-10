import 'package:flutter_test/flutter_test.dart';
import 'package:horror_flame/features/audio/audio_manager.dart';

/// Phase 7 tests — pure data-layer tests only.
///
/// Tests requiring platform channels (IAP, SharedPreferences) are
/// excluded from CI. Run on a device with:
///   flutter test test/phase7_tests.dart --device-id=<id>
void main() {

  // ── SkinDefinition (pure data) ─────────────────────────────
  group('SkinDefinition', () {
    test('has exactly 4 skins', () {
      expect(SkinDefinition.all.length, equals(4));
    });

    test('first skin is free', () {
      final first = SkinDefinition.all.first;
      expect(first.unlockType, equals(UnlockType.free));
      expect(first.id, equals('ashen_knight'));
    });

    test('Void Stalker is achievement unlock', () {
      final vs = SkinDefinition.all.firstWhere((s) => s.id == 'void_stalker');
      expect(vs.unlockType, equals(UnlockType.achievement));
      expect(vs.productId,  isNull);
    });

    test('IAP skins have product IDs', () {
      final iap = SkinDefinition.all
          .where((s) => s.unlockType == UnlockType.iap)
          .toList();
      expect(iap.length, equals(2));
      for (final skin in iap) {
        expect(skin.productId, isNotNull);
        expect(skin.productId!.startsWith('com.veilborn'), isTrue);
      }
    });

    test('all skins have unique IDs', () {
      final ids = SkinDefinition.all.map((s) => s.id).toSet();
      expect(ids.length, equals(SkinDefinition.all.length));
    });
  });

  // ── VeilbornProducts (pure constants) ──────────────────────
  group('VeilbornProducts', () {
    test('set contains both IAP SKUs', () {
      expect(VeilbornProducts.all.contains(VeilbornProducts.crimsonSeraph), isTrue);
      expect(VeilbornProducts.all.contains(VeilbornProducts.goldenWarden),  isTrue);
    });

    test('fallback prices set for all IAP products', () {
      for (final id in VeilbornProducts.all) {
        expect(VeilbornProducts.fallbackPrices.containsKey(id), isTrue);
      }
    });

    test('fallback prices match expected values', () {
      expect(VeilbornProducts.fallbackPrices[VeilbornProducts.crimsonSeraph],
          equals(r'$1.99'));
      expect(VeilbornProducts.fallbackPrices[VeilbornProducts.goldenWarden],
          equals(r'$2.99'));
    });
  });

  // ── AudioManager (singleton, no platform calls) ────────────
  group('AudioManager', () {
    test('is a singleton', () {
      expect(identical(AudioManager.instance, AudioManager.instance), isTrue);
    });

    test('SFX catalogue is non-empty', () {
      expect(Sfx.all.isNotEmpty, isTrue);
    });

    test('all SFX filenames end with .ogg', () {
      for (final sfx in Sfx.all) {
        expect(sfx.endsWith('.ogg'), isTrue, reason: '$sfx should end .ogg');
      }
    });

    test('BGM constants are non-empty .ogg strings', () {
      final tracks = [
        Bgm.mainMenu, Bgm.ch1Explore, Bgm.ch1Boss,
        Bgm.ch2Explore, Bgm.ch2Boss, Bgm.gameOver,
      ];
      for (final t in tracks) {
        expect(t.isNotEmpty, isTrue);
        expect(t.endsWith('.ogg'), isTrue);
      }
    });

    test('volume clamping — no exception thrown', () {
      // Does NOT call platform audio; only updates internal double fields
      AudioManager.instance.setMasterVolume(2.0);   // clamped to 1.0
      AudioManager.instance.setMasterVolume(-0.5);  // clamped to 0.0
      // Restore for other tests
      AudioManager.instance.setMasterVolume(1.0);
    });
  });
}
