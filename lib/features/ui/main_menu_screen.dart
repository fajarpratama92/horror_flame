import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/audio_manager.dart';
import 'character_select_screen.dart';
import 'settings_screen.dart';
import '../shop/cosmetic_shop_screen.dart';

/// Main menu — the hub players return to between runs.
///
/// Layout: animated background parallax, game title, nav buttons.
/// Navigation: Play → CharacterSelect → ChapterSelect → Game
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _entranceCtrl;
  late Animation<double>   _entranceFade;
  late Animation<Offset>   _entranceSlide;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _entranceFade  = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _onPlay() {
    AudioManager.instance.playSfx(Sfx.uiSelect);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:     (_, __, ___) => const CharacterSelectScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onShop() {
    AudioManager.instance.playSfx(Sfx.uiSelect);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CosmeticShopScreen()),
    );
  }

  void _onSettings() {
    AudioManager.instance.playSfx(Sfx.uiSelect);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A14),
      body: Stack(
        children: [
          // ── Animated background ──────────────────────────
          Positioned.fill(child: _AnimatedBackground(ctrl: _bgCtrl)),

          // ── Content ──────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _entranceSlide,
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Title block ───────────────────────
                    Column(
                      children: [
                        // Decorative line
                        Container(
                          width: 40,
                          height: 0.5,
                          color: const Color(0xFF3A3550),
                          margin: const EdgeInsets.only(bottom: 20),
                        ),
                        const Text(
                          'VEILBORN',
                          style: TextStyle(
                            color: Color(0xFFE8E4FF),
                            fontSize: 42,
                            fontWeight: FontWeight.w200,
                            letterSpacing: .4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Survive what\'s left of it.',
                          style: TextStyle(
                            color: Color(0xFF5F5E5A),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 0.5,
                          color: const Color(0xFF3A3550),
                          margin: const EdgeInsets.only(top: 20),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // ── Navigation buttons ────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          _MenuButton(
                            label:     'PLAY',
                            isPrimary: true,
                            onTap:     _onPlay,
                          ),
                          const SizedBox(height: 12),
                          _MenuButton(
                            label:     'SKINS',
                            isPrimary: false,
                            onTap:     _onShop,
                          ),
                          const SizedBox(height: 12),
                          _MenuButton(
                            label:     'SETTINGS',
                            isPrimary: false,
                            onTap:     _onSettings,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Version tag ───────────────────────
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        'v0.1.0 · AI Game Studio',
                        style: TextStyle(
                          color: Color(0xFF2A2535),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated background ───────────────────────────────────
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.ctrl});
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BgPainter(progress: ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  const _BgPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: const [Color(0xFF0D0A14), Color(0xFF12101A), Color(0xFF0A0814)],
        ).createShader(Offset.zero & size),
    );

    final paint = Paint()..style = PaintingStyle.fill;
    final rng   = math.Random(42);

    // Floating Veil particles
    for (int i = 0; i < 18; i++) {
      final x     = (rng.nextDouble() * size.width);
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.02 + rng.nextDouble() * 0.04;
      final y     = (baseY - progress * speed * size.height * 3) % size.height;
      final r     = 1.0 + rng.nextDouble() * 2.5;

      paint.color = Color.fromRGBO(
        107, 63, 160,
        0.08 + rng.nextDouble() * 0.12,
      );
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // Subtle vignette
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            const Color(0xFF0D0A14).withOpacity(0.6),
          ],
          stops: const [0.5, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.progress != progress;
}

// ── Menu button ───────────────────────────────────────────
class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });
  final String     label;
  final bool       isPrimary;
  final VoidCallback onTap;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp:   (_) { _pressCtrl.forward(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.forward(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, child) => Transform.scale(
          scale: _pressCtrl.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? const Color(0xFF6B3FA0)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isPrimary
                  ? const Color(0xFF6B3FA0)
                  : const Color(0xFF3A3550),
              width: 0.5,
            ),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.isPrimary
                  ? const Color(0xFFE8E4FF)
                  : const Color(0xFF9A9AB0),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: .1,
            ),
          ),
        ),
      ),
    );
  }
}
