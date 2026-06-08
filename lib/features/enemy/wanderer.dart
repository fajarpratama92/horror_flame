import 'package:flame/components.dart';
import 'base_enemy_component.dart';
import 'package:flutter/material.dart';

/// Wanderer — Tier 1 common enemy.
///
/// Behaviour: Patrol → detect player → chase → melee rush → attack
/// HP: 30 | Damage: 10 | Speed: medium | Sanity drain: none
/// Drop: 5 Soul Essence
class Wanderer extends BaseEnemyComponent {
  Wanderer({required super.position})
      : super(size: Vector2(28, 40), hp: 30);

  // ── Stats ─────────────────────────────────────────────────
  @override String get enemyName       => 'Wanderer';
  @override double get moveSpeed       => 90.0;
  @override double get attackDamage    => 10.0;
  @override double get sanityDrainOnHit => 0.0; // No sanity drain
  @override double get detectionRange  => 200.0;
  @override double get attackRange     => 45.0;
  @override double get soulEssenceDrop => 5.0;

  // ── State tracking ────────────────────────────────────────
  double _patrolTimer   = 0.0;
  double _patrolDir     = 1.0; // 1 = right, -1 = left
  static const double _patrolTurnInterval = 3.5; // seconds

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // TODO: add SpriteAnimationGroupComponent with wanderer sprite sheets
    // Placeholder: paint rectangle with distinct colour
    add(
      RectangleComponent(
        size: size,
        paint: _wandererPaint(),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _patrolTimer += dt;
    if (_patrolTimer >= _patrolTurnInterval) {
      _patrolTimer = 0;
      _patrolDir  *= -1;
      facingRight  = _patrolDir > 0;
    }
  }

  // ── Behaviour overrides ───────────────────────────────────
  @override
  void onPatrolBehaviour() {
    // Patrol uses timed direction reversal (updated in update())
    velocity.x = _patrolDir * moveSpeed * 0.5;
  }

  @override
  void onChaseBehaviour() {
    // Play run animation
    // TODO: anim.current = WandererState.run;
  }

  @override
  void onAttackBehaviour() {
    // Melee swipe — lunge forward slightly
    velocity.x = facingRight ? moveSpeed * 1.5 : -moveSpeed * 1.5;
    Future.delayed(const Duration(milliseconds: 200), () {
      velocity.x = 0;
    });
    // TODO: play attack animation
  }

  @override
  void onDeathBehaviour() {
    // TODO: play death animation, spawn essence particle
  }

  // ── Paint ─────────────────────────────────────────────────
  static Paint _wandererPaint() => Paint()
    ..color = const Color(0xFF3A3550); // Ashen grey
}
