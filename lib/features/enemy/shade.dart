import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'base_enemy_component.dart';
import 'package:flutter/material.dart';

/// Shade — Tier 2 elite enemy.
///
/// Teleports between shadow positions, fires shadow bolt projectiles.
/// HP: 60 | Damage: 20 | Speed: teleport | Sanity drain: −10 per hit
/// Drop: 20 Soul Essence
class Shade extends BaseEnemyComponent {
  Shade({required super.position})
      : super(size: Vector2(28, 42), hp: 60);

  @override String get enemyName        => 'Shade';
  @override double get moveSpeed        => 0.0; // Teleports, doesn't walk
  @override double get attackDamage     => 20.0;
  @override double get sanityDrainOnHit  => 1.0; // triggers drainSanityOnHit (−10)
  @override double get detectionRange   => 260.0;
  @override double get attackRange      => 180.0; // ranged attacker
  @override double get soulEssenceDrop  => 20.0;

  bool _isTeleporting = false;
  double _teleportCooldown = 0.0;
  static const double _teleportCooldownTime = 2.5;
  static const double _shadowBoltSpeed = 280.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF26215C)
          ..style = PaintingStyle.fill,
      ),
    );
    // Shades are semi-transparent like Wraiths
    add(OpacityEffect.to(0.85, EffectController(duration: 0)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_teleportCooldown > 0) _teleportCooldown -= dt;
  }

  @override
  void onChaseBehaviour() {
    // Shade doesn't walk — it teleports to maintain optimal range
    velocity.x = 0;
    if (_teleportCooldown <= 0 && ai.distanceToPlayer > 100) {
      _teleportBehindPlayer();
    }
  }

  @override
  void onAttackBehaviour() {
    _fireShadowBolt();
    // After attacking, teleport away
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!isDead) _teleportToRandomShadow();
    });
  }

  void _teleportBehindPlayer() {
    if (_isTeleporting) return;
    _isTeleporting = true;
    _teleportCooldown = _teleportCooldownTime;

    // Fade out, reposition, fade in
    add(
      SequenceEffect([
        OpacityEffect.to(0.0, EffectController(duration: 0.15)),
      ]),
    );

    Future.delayed(const Duration(milliseconds: 160), () {
      if (isDead) return;
      // Teleport to opposite side of player
      // In full impl: get player position from world
      position.x += facingRight ? -120 : 120;
      facingRight = !facingRight;
      _isTeleporting = false;
      add(OpacityEffect.to(0.85, EffectController(duration: 0.2)));
    });
  }

  void _teleportToRandomShadow() {
    if (_isTeleporting || isDead) return;
    _isTeleporting = true;

    add(SequenceEffect([
      OpacityEffect.to(0.0, EffectController(duration: 0.12)),
    ]));

    Future.delayed(const Duration(milliseconds: 130), () {
      if (isDead) return;
      // Random offset teleport within detection range
      position.x += (facingRight ? 1 : -1) * (80 + 40 * (DateTime.now().millisecond % 3));
      _isTeleporting = false;
      add(OpacityEffect.to(0.85, EffectController(duration: 0.15)));
    });
  }

  void _fireShadowBolt() {
    // Spawn projectile in direction of player
    final dir = facingRight ? Vector2(1, -0.1) : Vector2(-1, -0.1);
    gameRef.world.add(
      ShadowBolt(
        position: position + Vector2(facingRight ? size.x : 0, size.y * 0.3),
        direction: dir,
        damage: attackDamage,
        drainsSanity: true,
      ),
    );
  }
}

/// Shadow bolt projectile fired by Shade enemies.
class ShadowBolt extends PositionComponent with CollisionCallbacks {
  ShadowBolt({
    required super.position,
    required this.direction,
    required this.damage,
    this.drainsSanity = false,
  }) : super(size: Vector2(16, 10));

  final Vector2 direction;
  final double  damage;
  final bool    drainsSanity;

  static const double _speed  = 280.0;
  static const double _maxAge = 1.5;
  double _age = 0.0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF3C3489),
      ),
    );
  }

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _maxAge) { removeFromParent(); return; }
    position += direction * _speed * dt;
  }
}
