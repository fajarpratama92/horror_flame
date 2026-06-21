import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'skin_catalog.dart';

/// All purchasable product IDs — must match App Store / Google Play exactly.

/// Skin catalogue — all 4 skins with unlock logic.

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
