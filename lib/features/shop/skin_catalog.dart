/// Pure-data skin catalogue — no platform-channel dependencies.
///
/// Extracted from iap_service.dart so test files can import
/// SkinDefinition / UnlockType / VeilbornProducts without pulling
/// in package:in_app_purchase (which requires a native platform channel
/// and crashes headless Linux CI test runners).
///
/// iap_service.dart re-exports everything from here so existing
/// call-sites are unaffected.

enum UnlockType { free, achievement, iap }

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
  final String?    productId;   // null for free / achievement skins

  // ── Skin catalogue ─────────────────────────────────────────────
  static const List<SkinDefinition> all = [
    SkinDefinition(
      id:          'ashen_knight',
      name:        'Ashen Knight',
      description: 'The default survivor — battered plate, hollow visor.',
      unlockType:  UnlockType.free,
    ),
    SkinDefinition(
      id:          'void_stalker',
      name:        'Void Stalker',
      description: 'Earned by those who endure. Dark indigo with Veil-thread trim.',
      unlockType:  UnlockType.achievement,
    ),
    SkinDefinition(
      id:          'crimson_seraph',
      name:        'Crimson Seraph',
      description: 'A fallen guardian's colours. Deep crimson with ivory accents.',
      unlockType:  UnlockType.iap,
      productId:   'com.veilborn.skin_crimson_seraph',
    ),
    SkinDefinition(
      id:          'golden_warden',
      name:        'Golden Warden',
      description: 'Stone-gold and amber — a tribute to those who held the gate.',
      unlockType:  UnlockType.iap,
      productId:   'com.veilborn.skin_golden_warden',
    ),
  ];
}

/// IAP product ID constants — single source of truth.
class VeilbornProducts {
  VeilbornProducts._();

  static const String crimsonSeraph = 'com.veilborn.skin_crimson_seraph';
  static const String goldenWarden  = 'com.veilborn.skin_golden_warden';

  static const Set<String> all = {crimsonSeraph, goldenWarden};

  /// Fallback display prices shown while the store is loading.
  static const Map<String, String> fallbackPrices = {
    crimsonSeraph: r'$1.99',
    goldenWarden:  r'$2.99',
  };
}
