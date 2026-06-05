import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'iap_service.dart';
import '../save/save_manager.dart';

/// Riverpod provider for the cosmetic shop state.
///
/// Manages: owned skins, equipped skin, purchase in-progress state.
class ShopNotifier extends AsyncNotifier<ShopState> {
  late final SaveManager _save;

  @override
  Future<ShopState> build() async {
    _save = SaveManager();
    await _save.init();

    // Wire IAP callbacks → state updates
    IapService.instance.onPurchaseDelivered = _onPurchaseDelivered;
    IapService.instance.onPurchaseFailed    = _onPurchaseFailed;

    final owned    = _save.unlockedSkins;
    final equipped = owned.first; // default to first owned

    return ShopState(
      ownedSkins:    owned,
      equippedSkin:  equipped,
      purchasePending: false,
      lastError:     null,
    );
  }

  // ── Actions ───────────────────────────────────────────────
  Future<void> equipSkin(String skinId) async {
    final current = state.value;
    if (current == null || !current.ownedSkins.contains(skinId)) return;
    state = AsyncData(current.copyWith(equippedSkin: skinId));
    // Persist equipped skin choice
    await _save.saveSettings(
      _save.settings.copyWith(), // settings unchanged; extend SaveManager for equipped skin
    );
  }

  Future<void> purchaseSkin(String productId) async {
    final current = state.value;
    if (current == null) return;

    // Map product ID → skin ID
    final skinId = _skinIdFor(productId);
    if (skinId == null) return;

    // Already owned?
    if (current.ownedSkins.contains(skinId)) return;

    state = AsyncData(current.copyWith(purchasePending: true, lastError: null));
    await IapService.instance.purchase(productId);
    // Result delivered via onPurchaseDelivered / onPurchaseFailed callbacks
  }

  Future<void> restorePurchases() async {
    await IapService.instance.restorePurchases();
    // Deliveries come through onPurchaseDelivered
  }

  // ── IAP callbacks ─────────────────────────────────────────
  Future<void> _onPurchaseDelivered(String productId) async {
    final skinId = _skinIdFor(productId);
    if (skinId == null) return;

    await _save.unlockSkin(skinId);
    final owned = _save.unlockedSkins;

    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(
        ownedSkins:      owned,
        purchasePending: false,
        lastError:       null,
      ));
    }
  }

  void _onPurchaseFailed(String productId, String error) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(
        purchasePending: false,
        lastError:       error,
      ));
    }
  }

  String? _skinIdFor(String productId) => switch (productId) {
    'com.veilborn.skin.crimson_seraph' => 'crimson_seraph',
    'com.veilborn.skin.golden_warden'  => 'golden_warden',
    _                                  => null,
  };

  // ── Achievement unlock ────────────────────────────────────
  Future<void> unlockAchievementSkin(String skinId) async {
    await _save.unlockSkin(skinId);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(
        ownedSkins: _save.unlockedSkins,
      ));
    }
  }
}

final shopProvider =
    AsyncNotifierProvider<ShopNotifier, ShopState>(ShopNotifier.new);

// ── State model ───────────────────────────────────────────
class ShopState {
  const ShopState({
    required this.ownedSkins,
    required this.equippedSkin,
    required this.purchasePending,
    required this.lastError,
  });

  final List<String> ownedSkins;
  final String       equippedSkin;
  final bool         purchasePending;
  final String?      lastError;

  bool owns(String skinId) => ownedSkins.contains(skinId);

  ShopState copyWith({
    List<String>? ownedSkins,
    String?       equippedSkin,
    bool?         purchasePending,
    String?       lastError,
  }) => ShopState(
    ownedSkins:      ownedSkins      ?? this.ownedSkins,
    equippedSkin:    equippedSkin    ?? this.equippedSkin,
    purchasePending: purchasePending ?? this.purchasePending,
    lastError:       lastError,
  );
}
