import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shop/iap_service.dart';
import '../shop/shop_provider.dart';
import '../audio/audio_manager.dart';
import 'chapter_select_screen.dart';

/// Character (skin) select screen.
///
/// Horizontal carousel — swipe between skins, tap Equip or Buy.
/// Routes to ChapterSelectScreen when Play is tapped.
class CharacterSelectScreen extends ConsumerStatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  ConsumerState<CharacterSelectScreen> createState() =>
      _CharacterSelectScreenState();
}

class _CharacterSelectScreenState
    extends ConsumerState<CharacterSelectScreen> {
  late final PageController _pageCtrl;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.78, initialPage: 0);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onPlay() {
    AudioManager.instance.playSfx(Sfx.uiSelect);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ChapterSelectScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF9A9AB0), size: 18),
          onPressed: () {
            AudioManager.instance.playSfx(Sfx.uiBack);
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Choose your vessel',
          style: TextStyle(
            color: Color(0xFF9A9AB0),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: shopAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B3FA0)),
        ),
        error: (e, _) => Center(
          child: Text('$e',
              style: const TextStyle(color: Color(0xFF8B1A1A))),
        ),
        data: (shop) => Column(
          children: [
            const SizedBox(height: 24),

            // ── Skin carousel ─────────────────────────────
            SizedBox(
              height: 340,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: SkinDefinition.all.length,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  AudioManager.instance.playSfx(Sfx.uiSelect);
                },
                itemBuilder: (context, i) {
                  final skin = SkinDefinition.all[i];
                  final isActive = i == _currentPage;
                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.88,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: _SkinCarouselCard(
                      skin:      skin,
                      shop:      shop,
                      isActive:  isActive,
                    ),
                  );
                },
              ),
            ),

            // ── Page dots ─────────────────────────────────
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                SkinDefinition.all.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  i == _currentPage ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? const Color(0xFF6B3FA0)
                        : const Color(0xFF3A3550),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Skin name + description ───────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Padding(
                key: ValueKey(_currentPage),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      SkinDefinition.all[_currentPage].name,
                      style: const TextStyle(
                        color: Color(0xFFE8E4FF),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      SkinDefinition.all[_currentPage].description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF5F5E5A),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ── Action area ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: _ActionArea(
                skin:    SkinDefinition.all[_currentPage],
                shop:    shop,
                onEquip: () => ref
                    .read(shopProvider.notifier)
                    .equipSkin(SkinDefinition.all[_currentPage].id),
                onBuy: () => ref
                    .read(shopProvider.notifier)
                    .purchaseSkin(
                        SkinDefinition.all[_currentPage].productId!),
                onPlay:  _onPlay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carousel card ─────────────────────────────────────────
class _SkinCarouselCard extends StatelessWidget {
  const _SkinCarouselCard({
    required this.skin,
    required this.shop,
    required this.isActive,
  });
  final SkinDefinition skin;
  final ShopState      shop;
  final bool           isActive;

  bool get isOwned => shop.owns(skin.id);
  bool get isEquipped => shop.equippedSkin == skin.id;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(skin.id);
    return Opacity(
      opacity: isOwned ? 1.0 : 0.55,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [colors.$1, colors.$2],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEquipped
                ? const Color(0xFF6B3FA0)
                : isActive
                    ? colors.$3.withOpacity(0.5)
                    : const Color(0xFF2A2535),
            width: isEquipped ? 1.5 : 0.5,
          ),
          boxShadow: isActive
              ? [BoxShadow(
                  color: colors.$3.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 2,
                )]
              : null,
        ),
        child: Stack(
          children: [
            // Lock overlay
            if (!isOwned)
              Positioned(
                top: 16, right: 16,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF5F5E5A),
                    size: 16,
                  ),
                ),
              ),

            // Equipped badge
            if (isEquipped)
              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B3FA0).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Equipped',
                    style: TextStyle(
                      color: Color(0xFFE8E4FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Character silhouette
            Center(
              child: _CharacterSilhouette(
                skinId:  skin.id,
                color:   colors.$3,
                isOwned: isOwned,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, Color) _colorsFor(String id) => switch (id) {
    'ashen_knight'   => (const Color(0xFF1A1626), const Color(0xFF0D0A14), const Color(0xFF888780)),
    'void_stalker'   => (const Color(0xFF0D0A14), const Color(0xFF0A0814), const Color(0xFF6B3FA0)),
    'crimson_seraph' => (const Color(0xFF1A0808), const Color(0xFF0D0A14), const Color(0xFF8B1A1A)),
    'golden_warden'  => (const Color(0xFF141008), const Color(0xFF0D0A14), const Color(0xFFEF9F27)),
    _                => (const Color(0xFF1A1626), const Color(0xFF0D0A14), const Color(0xFF3A3550)),
  };
}

class _CharacterSilhouette extends StatelessWidget {
  const _CharacterSilhouette({
    required this.skinId,
    required this.color,
    required this.isOwned,
  });
  final String skinId;
  final Color  color;
  final bool   isOwned;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 160),
      painter: _SilhouettePainter(color: color),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(s.width/2, s.height*0.18),
          width: s.width*0.38, height: s.height*0.22), p);
    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.28, s.height*0.30,
            s.width*0.44, s.height*0.38),
        const Radius.circular(4)),
      p);
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.08, s.height*0.30,
            s.width*0.18, s.height*0.30),
        const Radius.circular(3)),
      p);
    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.74, s.height*0.30,
            s.width*0.18, s.height*0.30),
        const Radius.circular(3)),
      p);
    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.28, s.height*0.66,
            s.width*0.18, s.height*0.32),
        const Radius.circular(3)),
      p);
    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.54, s.height*0.66,
            s.width*0.18, s.height*0.32),
        const Radius.circular(3)),
      p);
    // Weapon
    p.color = color.withOpacity(0.6);
    p.strokeWidth = 3;
    p.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(s.width*0.83, s.height*0.22),
      Offset(s.width*0.74, s.height*0.58),
      p);
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => old.color != color;
}

// ── Action area ───────────────────────────────────────────
class _ActionArea extends StatelessWidget {
  const _ActionArea({
    required this.skin,
    required this.shop,
    required this.onEquip,
    required this.onBuy,
    required this.onPlay,
  });
  final SkinDefinition skin;
  final ShopState      shop;
  final VoidCallback   onEquip, onBuy, onPlay;

  bool get isOwned    => shop.owns(skin.id);
  bool get isEquipped => shop.equippedSkin == skin.id;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Equip / Buy row
        if (!isEquipped && isOwned)
          _Btn(
            label: 'Equip',
            color: const Color(0xFF2A6B5C),
            onTap: onEquip,
            fullWidth: true,
          ),
        if (!isOwned && skin.unlockType == UnlockType.iap)
          _Btn(
            label: 'Buy — ${IapService.instance.priceFor(skin.productId!)}',
            color: const Color(0xFF6B3FA0),
            onTap: shop.purchasePending ? null : onBuy,
            fullWidth: true,
          ),
        if (!isOwned && skin.unlockType == UnlockType.achievement)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Clear Chapter 1 to unlock this skin',
              style: TextStyle(color: Color(0xFF5F5E5A), fontSize: 12),
            ),
          ),

        const SizedBox(height: 12),

        // Play button
        _Btn(
          label:     'PLAY',
          color:     isEquipped
              ? const Color(0xFF6B3FA0)
              : const Color(0xFF3A3550),
          onTap:     onPlay,
          fullWidth:  true,
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });
  final String       label;
  final Color        color;
  final VoidCallback? onTap;
  final bool         fullWidth;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: onTap == null ? color.withOpacity(0.3) : color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFE8E4FF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: .06,
          ),
        ),
      ),
    ),
  );
}
