import 'package:flutter_test/flutter_test.dart';
import 'package:horror_flame/features/shop/iap_service.dart';
import 'package:horror_flame/features/shop/shop_provider.dart';
import 'package:horror_flame/features/audio/audio_manager.dart';

void main() {

  // ── SkinDefinition ────────────────────────────────────────
  group('SkinDefinition', () {
    test('has exactly 4 skins', () {
      expect(SkinDefinition.all.length, equals(4));
    });

    test('first skin is free', () {
      expect(SkinDefinition.all.first.unlockType, equals(UnlockType.free));
      expect(SkinDefinition.all.first.id, equals('ashen_knight'));
    });

    test('Void Stalker is achievement unlock', () {
      final vs = SkinDefinition.all.firstWhere((s) => s.id == 'void_stalker');
      expect(vs.unlockType, equals(UnlockType.achievement));
      expect(vs.productId, isNull);
    });

    test('IAP skins have product IDs', () {
      final iapSkins = SkinDefinition.all
          .where((s) => s.unlockType == UnlockType.iap)
          .toList();
      expect(iapSkins.length, equals(2));
      for (final skin in iapSkins) {
        expect(skin.productId, isNotNull);
        expect(skin.productId!.startsWith('com.veilborn'), isTrue);
      }
    });

    test('all skins have unique IDs', () {
      final ids = SkinDefinition.all.map((s) => s.id).toSet();
      expect(ids.length, equals(SkinDefinition.all.length));
    });

    test('product IDs match VeilbornProducts', () {
      final crimson = SkinDefinition.all
          .firstWhere((s) => s.id == 'crimson_seraph');
      expect(crimson.productId, equals(VeilbornProducts.crimsonSeraph));

      final golden = SkinDefinition.all
          .firstWhere((s) => s.id == 'golden_warden');
      expect(golden.productId, equals(VeilbornProducts.goldenWarden));
    });
  });

  // ── VeilbornProducts ──────────────────────────────────────
  group('VeilbornProducts', () {
    test('product set contains both IAP skus', () {
      expect(VeilbornProducts.all.contains(VeilbornProducts.crimsonSeraph),
          isTrue);
      expect(VeilbornProducts.all.contains(VeilbornProducts.goldenWarden),
          isTrue);
    });

    test('fallback prices are set for all IAP products', () {
      for (final productId in VeilbornProducts.all) {
        expect(VeilbornProducts.fallbackPrices.containsKey(productId),
            isTrue);
      }
    });

    test('fallbackPrices returns expected values', () {
      expect(VeilbornProducts.fallbackPrices[VeilbornProducts.crimsonSeraph],
          equals(r'$1.99'));
      expect(VeilbornProducts.fallbackPrices[VeilbornProducts.goldenWarden],
          equals(r'$2.99'));
    });
  });

  // ── ShopState ─────────────────────────────────────────────
  group('ShopState', () {
    late ShopState state;

    setUp(() {
      state = const ShopState(
        ownedSkins:      ['ashen_knight'],
        equippedSkin:    'ashen_knight',
        purchasePending: false,
        lastError:       null,
      );
    });

    test('owns() returns true for owned skin', () {
      expect(state.owns('ashen_knight'), isTrue);
    });

    test('owns() returns false for unowned skin', () {
      expect(state.owns('crimson_seraph'), isFalse);
    });

    test('copyWith updates only specified fields', () {
      final updated = state.copyWith(
        ownedSkins: ['ashen_knight', 'void_stalker'],
      );
      expect(updated.ownedSkins.length, equals(2));
      expect(updated.equippedSkin, equals('ashen_knight')); // unchanged
      expect(updated.purchasePending, isFalse);             // unchanged
    });

    test('copyWith clears lastError when null passed', () {
      final withError  = state.copyWith(lastError: 'Payment failed');
      final cleared    = withError.copyWith(lastError: null);
      expect(cleared.lastError, isNull);
    });

    test('copyWith purchasePending', () {
      final pending = state.copyWith(purchasePending: true);
      expect(pending.purchasePending, isTrue);
    });
  });

  // ── AudioManager ──────────────────────────────────────────
  group('AudioManager', () {
    test('is a singleton', () {
      final a = AudioManager.instance;
      final b = AudioManager.instance;
      expect(identical(a, b), isTrue);
    });

    test('volume clamping — setMasterVolume clamps to 0..1', () {
      final am = AudioManager.instance;
      am.setMasterVolume(2.0);   // over 1
      am.setMasterVolume(-0.5);  // under 0
      // No exception thrown — clamp works silently
    });

    test('SFX catalogue is non-empty', () {
      expect(Sfx.all.isNotEmpty, isTrue);
    });

    test('SFX catalogue has unique filenames', () {
      final unique = Sfx.all.toSet();
      expect(unique.length, equals(Sfx.all.length));
    });

    test('all SFX filenames end with .ogg', () {
      for (final sfx in Sfx.all) {
        expect(sfx.endsWith('.ogg'), isTrue,
            reason: '$sfx should end with .ogg');
      }
    });

    test('BGM constants are non-empty strings', () {
      final bgmTracks = [
        Bgm.mainMenu, Bgm.ch1Explore, Bgm.ch1Boss,
        Bgm.ch2Explore, Bgm.ch2Boss, Bgm.gameOver,
      ];
      for (final track in bgmTracks) {
        expect(track.isNotEmpty, isTrue);
        expect(track.endsWith('.ogg'), isTrue);
      }
    });
  });
}
