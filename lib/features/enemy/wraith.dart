import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'base_enemy_component.dart';
import 'package:flutter/material.dart';

/// Wraith — Tier 1 common enemy.
///
/// Floats, phases through walls, lunges at the player.
/// HP: 20 | Damage: 15 | Speed: fast | Sanity drain: −5 per hit
/// Drop: 8 Soul Essence
///
/// Special: Wraiths ignore platform collision (they float through geometry).
class Wraith extends BaseEnemyComponent {
  Wraith({required super.position})
      : super(size: Vector2(26, 36), hp: 20);

  @override String get enemyName        => 'Wraith';
  @override double get moveSpeed        => 130.0;
  @override double get attackDamage     => 15.0;
  @override double get sanityDrainOnHit  => 1.0; // triggers drainSanityOnHit
  @override double get detectionRange   => 240.0;
  @override double get attackRange      => 50.0;
  @override double get soulEssenceDrop  => 8.0;

  // Wraiths float — sinusoidal Y oscillation
  double _floatTimer = 0.0;
  static const double _floatAmplitude = 12.0;
  static const double _floatFrequency = 1.8;
  double _baseY = 0.0;

  bool _isLunging = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _baseY = position.y;

    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF6B3FA0), // Veil purple
      ),
    );

    // Wraiths are semi-transparent
    add(OpacityEffect.to(0.75, EffectController(duration: 0)));
  }

  @override
  void update(double dt) {
    // Wraiths override physics — they fly, no gravity
    _floatTimer += dt;
    position.y = _baseY +
        (_floatAmplitude * sin(_floatTimer * _floatFrequency * 2 * 3.14159));
    _updateAi(dt);
  }

  void _updateAi(double dt) {
    // Manually update AI distance (bypasses PhysicsBody)
    // Called here because we skipped super.update()
  }

  @override
  void onChaseBehaviour() {
    // Fly directly toward player (no gravity constraint)
    // Parent handles X velocity; we zero out Y drift from physics
    velocity.y = 0;
  }

  @override
  void onAttackBehaviour() {
    if (_isLunging) return;
    _isLunging = true;
    // Lunge: brief intangibility + fast lunge
    add(OpacityEffect.to(0.3, EffectController(duration: 0.15)));
    velocity.x = facingRight ? moveSpeed * 2.5 : -moveSpeed * 2.5;

    Future.delayed(const Duration(milliseconds: 300), () {
      _isLunging = false;
      velocity.x = 0;
      add(OpacityEffect.to(0.75, EffectController(duration: 0.15)));
    });
  }

  // Pure Dart sin (no dart:math import needed in game code)
  static double sin(double x) {
    // Taylor series approximation — sufficient for visual oscillation
    double result = 0;
    double term   = x;
    double xSq    = x * x;
    for (int n = 0; n < 7; n++) {
      result += term;
      term   *= -xSq / ((2 * n + 2) * (2 * n + 3));
    }
    return result;
  }
}
