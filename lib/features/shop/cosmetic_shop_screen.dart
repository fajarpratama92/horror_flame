import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horror_flame/features/shop/skin_catalog.dart';
import '../../core/assets/asset_manifest.dart';
import '../audio/audio_manager.dart';
import 'iap_service.dart';
import 'shop_provider.dart';

/// Full cosmetic shop screen.
///
/// Displays all 4 skins with their unlock state:
/// - Free / unlocked → "Equip" button
/// - Achievement → shows unlock condition
/// - IAP → shows price, "Buy" button
class CosmeticShopScreen extends ConsumerWidget {
  const CosmeticShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Skins',
          style: TextStyle(
            color: Color(0xFFE8E4FF),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9A9AB0), size: 18),
          onPressed: () {
            AudioManager.instance.playSfx(SfxAssets.uiBack);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(shopProvider.notifier).restorePurchases(),
            child: const Text(
              'Restore',
              style: TextStyle(color: Color(0xFF6B3FA0), fontSize: 13),
            ),
          ),
        ],
      ),
      body: shopAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B3FA0)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Color(0xFF8B1A1A))),
        ),
        data: (shop) => Column(
          children: [
            // Error banner
            if (shop.lastError != null)
              _ErrorBanner(message: shop.lastError!),

            // Skin grid
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: SkinDefinition.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final skin = SkinDefinition.all[i];
                  return _SkinCard(
                    skin:        skin,
                    shop:        shop,
                    onEquip:     () {
                      AudioManager.instance.playSfx(SfxAssets.uiSelect);
                      ref.read(shopProvider.notifier).equipSkin(skin.id);
                    },
                    onBuy:       () {
                      AudioManager.instance.playSfx(SfxAssets.uiSelect);
                      ref.read(shopProvider.notifier).purchaseSkin(skin.productId!);
                    },
                    isBuying:    shop.purchasePending,
                  );
                },
              ),
            ),

            // No-ads promise
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(
                'Cosmetics only — zero gameplay advantage. No ads. Ever.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF5F5E5A), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skin card ─────────────────────────────────────────────
class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.skin,
    required this.shop,
    required this.onEquip,
    required this.onBuy,
    required this.isBuying,
  });

  final SkinDefinition skin;
  final ShopState      shop;
  final VoidCallback   onEquip;
  final VoidCallback   onBuy;
  final bool           isBuying;

  bool get isOwned    => shop.owns(skin.id);
  bool get isEquipped => shop.equippedSkin == skin.id;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEquipped
            ? const Color(0xFF6B3FA0).withOpacity(0.12)
            : const Color(0xFF12101A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEquipped
              ? const Color(0xFF6B3FA0)
              : const Color(0xFF2A2535),
          width: isEquipped ? 1.0 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // Skin preview
          _SkinPreview(skinId: skin.id, isOwned: isOwned),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      skin.name,
                      style: const TextStyle(
                        color: Color(0xFFE8E4FF),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isEquipped) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B3FA0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Equipped',
                          style: TextStyle(
                            color: Color(0xFFAFA9EC),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  skin.description,
                  style: const TextStyle(
                    color: Color(0xFF5F5E5A),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  skin:     skin,
                  isOwned:  isOwned,
                  isEquipped: isEquipped,
                  isBuying: isBuying,
                  onEquip:  onEquip,
                  onBuy:    onBuy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skin SVG preview ──────────────────────────────────────
class _SkinPreview extends StatelessWidget {
  const _SkinPreview({required this.skinId, required this.isOwned});

  final String skinId;
  final bool   isOwned;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(skinId);
    return Opacity(
      opacity: isOwned ? 1.0 : 0.35,
      child: Container(
        width: 64,
        height: 80,
        decoration: BoxDecoration(
          color: colors.$1,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.$2, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Head
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.$3,
                  border: Border.all(color: colors.$2, width: 1),
                ),
              ),
              const SizedBox(height: 2),
              // Body
              Container(
                width: 28,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.$3,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: colors.$2.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, Color) _colorsFor(String id) => switch (id) {
    'ashen_knight'   => (const Color(0xFF1A1626), const Color(0xFF888780), const Color(0xFF3A3550)),
    'void_stalker'   => (const Color(0xFF0D0A14), const Color(0xFF6B3FA0), const Color(0xFF1E1230)),
    'crimson_seraph' => (const Color(0xFF1A0808), const Color(0xFF8B1A1A), const Color(0xFF4A1515)),
    'golden_warden'  => (const Color(0xFF141008), const Color(0xFFEF9F27), const Color(0xFF3D2E08)),
    _                => (const Color(0xFF1A1626), const Color(0xFF3A3550), const Color(0xFF2A2535)),
  };
}

// ── Action button ─────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.skin,
    required this.isOwned,
    required this.isEquipped,
    required this.isBuying,
    required this.onEquip,
    required this.onBuy,
  });

  final SkinDefinition skin;
  final bool isOwned, isEquipped, isBuying;
  final VoidCallback onEquip, onBuy;

  @override
  Widget build(BuildContext context) {
    if (isEquipped) {
      return const SizedBox.shrink();
    }

    if (isOwned) {
      return _Btn(
        label: 'Equip',
        color: const Color(0xFF2A6B5C),
        onTap: onEquip,
      );
    }

    if (skin.unlockType == UnlockType.achievement) {
      return const Text(
        'Clear Chapter 1 to unlock',
        style: TextStyle(
          color: Color(0xFF5F5E5A),
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (skin.unlockType == UnlockType.iap) {
      final price = IapService.instance.priceFor(skin.productId!);
      return _Btn(
        label: isBuying ? 'Processing…' : 'Buy — $price',
        color: const Color(0xFF6B3FA0),
        onTap: isBuying ? null : onBuy,
      );
    }

    return const SizedBox.shrink();
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, this.onTap});
  final String     label;
  final Color      color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: onTap == null ? color.withOpacity(0.4) : color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE8E4FF),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF8B1A1A).withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF8B1A1A).withOpacity(0.4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFF8B1A1A), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFCC4444), fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
