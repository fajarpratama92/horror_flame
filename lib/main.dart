import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/game/veilborn_game.dart';
import 'core/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: GameConstants.gameTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6B3FA0),   // Veil purple
          secondary: Color(0xFFF5A623), // Candlelight
          surface: Color(0xFF0D0A14),   // Void black
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final VeilbornGame _game;

  @override
  void initState() {
    super.initState();
    _game = VeilbornGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A14),
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'HudOverlay': (context, game) => const HudOverlayPlaceholder(),
          'PauseMenu': (context, game) => const PauseMenuPlaceholder(),
        },
      ),
    );
  }
}

// Placeholder overlays — replaced by full implementations in Phase 5
class HudOverlayPlaceholder extends StatelessWidget {
  const HudOverlayPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // TODO: implement HUD
  }
}

class PauseMenuPlaceholder extends StatelessWidget {
  const PauseMenuPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // TODO: implement Pause Menu
  }
}
