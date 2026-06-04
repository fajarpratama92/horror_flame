import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'player_component.dart';

/// Bridges raw input (touch joystick + buttons, or keyboard) to
/// PlayerComponent action methods.
///
/// Attach to the game world. Holds refs to the virtual controls
/// created by MobileControlsOverlay.
class InputController extends Component with KeyboardHandler {
  InputController({required this.player});

  final PlayerComponent player;

  // ── Mobile input state (set by MobileControlsOverlay) ────
  bool moveLeft  = false;
  bool moveRight = false;

  // ── Keyboard state ───────────────────────────────────────
  final Set<LogicalKeyboardKey> _held = {};

  @override
  void update(double dt) {
    // Combine mobile + keyboard
    final goLeft  = moveLeft  || _held.contains(LogicalKeyboardKey.arrowLeft)
                               || _held.contains(LogicalKeyboardKey.keyA);
    final goRight = moveRight || _held.contains(LogicalKeyboardKey.arrowRight)
                               || _held.contains(LogicalKeyboardKey.keyD);

    if (goLeft)       player.moveLeft();
    else if (goRight) player.moveRight();
    else              player.stopMove();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _held
      ..clear()
      ..addAll(keysPressed);

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          player.jump();
        case LogicalKeyboardKey.keyZ:
        case LogicalKeyboardKey.keyJ:
          player.lightAttack();
        case LogicalKeyboardKey.keyX:
        case LogicalKeyboardKey.keyK:
          player.heavyAttack();
        case LogicalKeyboardKey.keyC:
        case LogicalKeyboardKey.keyL:
          player.rangedAttack();
        case LogicalKeyboardKey.shiftLeft:
        case LogicalKeyboardKey.shiftRight:
          player.dash();
      }
    }
    return true;
  }

  /// Called by jump button on mobile overlay
  void onJumpPressed()   => player.jump();
  void onAttackPressed() => player.lightAttack();
  void onHeavyPressed()  => player.heavyAttack();
  void onRangedPressed() => player.rangedAttack();
  void onDashPressed()   => player.dash();
}
