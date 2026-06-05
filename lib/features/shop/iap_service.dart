import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// All purchasable product IDs — must match App Store / Google Play exactly.
class VeilbornProducts {
  VeilbornProducts._();

  static const String crimsonSeraph = 'com.veilborn.skin.crimson_seraph';
  static const String goldenWarden  = 'com.veilborn.skin.golden_warden';

  static const Set<String> all = {crimsonSeraph, goldenWarden};

  /// Price display labels (fallback when store prices unavailable)
  static const Map<String, String> fallbackPrices = {
    crimsonSeraph: r'$1.99',
    goldenWarden:  r'$2.99',
  };
}

/// Skin catalogue — all 4 skins with unlock logic.
class SkinDefinition {
  const SkinDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockType,
    this.productId,
  });

  final String     id;
  final String     name;
  final String     description;
  final UnlockType unlockType;
  final String?    productId; // null for free/achievement skins

  static const List<SkinDefinition> all = [
    SkinDefinition(
      id:          'ashen_knight',
      name:        'Ashen Knight',
      description: 'Worn plate armour forged in the old kingdom. Battle-scarred, steadfast.',
      unlockType:  UnlockType.free,
    ),
    SkinDefinition(
      id:          'void_stalker',
      name:        'Void Stalker',
      description: 'A shadow that learned to walk. Cloak woven from the Veil itself.',
      unlockType:  UnlockType.achievement,
    ),
    SkinDefinition(
      id:          'crimson_seraph',
      name:        'Crimson Seraph',
      description: 'Fallen from grace. Horned helm, war scythe — a demon\'s elegance.',
      unlockType:  UnlockType.iap,
      productId:   VeilbornProducts.crimsonSeraph,
    ),
    SkinDefinition(
      id:          'golden_warden',
      name:        'Golden Warden',
      description: 'Guardian of a dead age. Gold-trimmed armour, rune-etched hammer.',
      unlockType:  UnlockType.iap,
      productId:   VeilbornProducts.goldenWarden,
    ),
  ];
}

enum UnlockType { free, achievement, iap }

/// Wraps Flutter's in_app_purchase plugin.
///
/// Responsibilities:
/// - Load product details from the store
/// - Initiate purchases
/// - Handle purchase updates (pending / success / error / restored)
/// - Deliver entitlements via [onPurchaseDelivered]
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Store-loaded product details (price, title, etc.)
  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  bool _available = false;
  bool get isAvailable => _available;

  // ── Callbacks ─────────────────────────────────────────────
  /// Called when a purchase is successfully delivered.
  void Function(String productId)? onPurchaseDelivered;

  /// Called when a purchase fails.
  void Function(String productId, String error)? onPurchaseFailed;

  // ── Lifecycle ─────────────────────────────────────────────
  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('[IAP] Store not available on this device');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) => debugPrint('[IAP] Stream error: $e'),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(VeilbornProducts.all);

    if (response.error != null) {
      debugPrint('[IAP] Product query error: ${response.error}');
    }

    for (final product in response.productDetails) {
      _products[product.id] = product;
      debugPrint('[IAP] Loaded: ${product.id} — ${product.price}');
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[IAP] Products not found: ${response.notFoundIDs}');
    }
  }

  // ── Purchase flow ─────────────────────────────────────────
  Future<bool> purchase(String productId) async {
    if (!_available) return false;

    final product = _products[productId];
    if (product == null) {
      debugPrint('[IAP] Product not loaded: $productId');
      return false;
    }

    final param = PurchaseParam(productDetails: product);
    try {
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('[IAP] Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  // ── Purchase update handler ───────────────────────────────
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('[IAP] Pending: ${purchase.productID}');

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliverPurchase(purchase);

        case PurchaseStatus.error:
          debugPrint('[IAP] Error on ${purchase.productID}: ${purchase.error}');
          onPurchaseFailed?.call(
            purchase.productID,
            purchase.error?.message ?? 'Unknown error',
          );

        case PurchaseStatus.canceled:
          debugPrint('[IAP] Cancelled: ${purchase.productID}');
      }

      // Always complete the purchase to avoid dangling transactions
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    debugPrint('[IAP] Delivering: ${purchase.productID}');
    // TODO post-MVP: validate receipt server-side before delivering
    onPurchaseDelivered?.call(purchase.productID);
  }

  // ── Price helpers ─────────────────────────────────────────
  String priceFor(String productId) {
    return _products[productId]?.price ??
        VeilbornProducts.fallbackPrices[productId] ??
        '—';
  }

  void dispose() {
    _subscription?.cancel();
  }
}
