import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive full-screen (hide status + nav bar)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    const ProviderScope(
      child: VeilbornApp(),
    ),
  );
}

class VeilbornApp extends StatelessWidget {
  const VeilbornApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veilborn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary:   Color(0xFF6B3FA0),
          secondary: Color(0xFFF5A623),
          surface:   Color(0xFF0D0A14),
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // Entry point: SplashScreen handles init + routes to MainMenu
      home: const SplashScreen(),
    );
  }
}
