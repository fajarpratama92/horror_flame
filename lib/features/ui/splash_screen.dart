import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/assets/asset_manifest.dart';
import '../../core/assets/asset_manager.dart';
import '../shop/iap_service.dart';
import '../audio/audio_manager.dart';
import '../save/save_manager.dart';
import 'main_menu_screen.dart';

/// Splash screen — first thing the user sees.
///
/// Responsibilities:
/// - Animated studio + game logo fade-in
/// - Parallel init: SaveManager, IapService, AudioManager
/// - Routes to MainMenuScreen when ready
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _subtitleCtrl;
  late Animation<double>   _logoFade;
  late Animation<double>   _logoScale;
  late Animation<double>   _subtitleFade;

  bool _initDone = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _subtitleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFade  = CurvedAnimation(parent: _logoCtrl,     curve: Curves.easeIn);
    _logoScale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _subtitleFade = CurvedAnimation(
        parent: _subtitleCtrl, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Start logo fade-in
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();

    // Start parallel init
    final initFuture = _initServices();

    // Subtitle fades in after logo
    await Future.delayed(const Duration(milliseconds: 900));
    _subtitleCtrl.forward();

    // Wait for both init + minimum display time
    await Future.wait([
      initFuture,
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);

    if (mounted) {
      setState(() => _initDone = true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainMenuScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  Future<void> _initServices() async {
    final save = SaveManager();
    await save.init();

    await Future.wait([
      IapService.instance.init(),
      AudioManager.instance.init(
        master: save.settings.masterVolume,
        sfx:    save.settings.sfxVolume,
        music:  save.settings.musicVolume,
      ),
    ]);

    // Preload Main Menu assets (like candle flame)
    await AssetManager.instance.preloadMainMenu();

    // Start main menu BGM
    await AudioManager.instance.playBgm(BgmAssets.mainMenu);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // ── Logo ──────────────────────────────────────
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Column(
                  children: [
                    // Candle flame icon
                    _CandleIcon(),
                    const SizedBox(height: 24),

                    // Game title
                    const Text(
                      'VEILBORN',
                      style: TextStyle(
                        color: Color(0xFFE8E4FF),
                        fontSize: 38,
                        fontWeight: FontWeight.w200,
                        letterSpacing: .35,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: const Text(
                        'The world died. You didn\'t.',
                        style: TextStyle(
                          color: Color(0xFF5F5E5A),
                          fontSize: 13,
                          letterSpacing: .04,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 2),

            // ── Loading indicator ─────────────────────────
            FadeTransition(
              opacity: _subtitleFade,
              child: AnimatedOpacity(
                opacity: _initDone ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: const Column(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Color(0xFF3A3550),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Entering the Veil…',
                      style: TextStyle(
                        color: Color(0xFF3A3550),
                        fontSize: 11,
                        letterSpacing: .04,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Studio tag ────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(bottom: 32),
              child: Text(
                'AI Game Studio',
                style: TextStyle(
                  color: Color(0xFF2A2535),
                  fontSize: 11,
                  letterSpacing: .06,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Candle icon ───────────────────────────────────────────
class _CandleIcon extends StatefulWidget {
  @override
  State<_CandleIcon> createState() => _CandleIconState();
}

class _CandleIconState extends State<_CandleIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _flickerCtrl;
  late Animation<double>   _flicker;

  @override
  void initState() {
    super.initState();
    _flickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _flicker = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _flickerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flicker,
      builder: (_, __) => CustomPaint(
        size: const Size(48, 64),
        painter: _CandlePainter(flicker: _flicker.value),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  const _CandlePainter({required this.flicker});
  final double flicker;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Candle body
    paint.color = const Color(0xFF3A3550);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.35,
            size.width * 0.3, size.height * 0.65),
        const Radius.circular(2),
      ),
      paint,
    );

    // Flame outer glow
    paint.color = Color.fromRGBO(245, 166, 35, 0.15 * flicker);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.22),
        width: 28 * flicker,
        height: 32 * flicker,
      ),
      paint,
    );

    // Flame body
    paint.color = Color.fromRGBO(245, 166, 35, 0.85 * flicker);
    final flamePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.04)
      ..quadraticBezierTo(
        size.width * 0.72, size.height * 0.18,
        size.width * 0.58, size.height * 0.34,
      )
      ..quadraticBezierTo(
        size.width * 0.5,  size.height * 0.38,
        size.width * 0.42, size.height * 0.34,
      )
      ..quadraticBezierTo(
        size.width * 0.28, size.height * 0.18,
        size.width * 0.5,  size.height * 0.04,
      );
    canvas.drawPath(flamePath, paint);

    // Flame inner highlight
    paint.color = Color.fromRGBO(255, 220, 130, 0.7 * flicker);
    final innerPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.10)
      ..quadraticBezierTo(
        size.width * 0.60, size.height * 0.20,
        size.width * 0.54, size.height * 0.30,
      )
      ..quadraticBezierTo(
        size.width * 0.5,  size.height * 0.32,
        size.width * 0.46, size.height * 0.30,
      )
      ..quadraticBezierTo(
        size.width * 0.40, size.height * 0.20,
        size.width * 0.5,  size.height * 0.10,
      );
    canvas.drawPath(innerPath, paint);
  }

  @override
  bool shouldRepaint(_CandlePainter old) => old.flicker != flicker;
}
