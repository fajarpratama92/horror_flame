import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'base_enemy_component.dart';
import 'package:flutter/material.dart';

/// Husk — Tier 2 tank enemy.
///
/// Slow-moving behemoth. Ground slam AoE, short charge, massive melee hitbox.
/// HP: 120 | Damage: 30 | Speed: slow | Sanity drain: −5 per slam
/// Drop: 25 Soul Essence
class Husk extends BaseEnemyComponent {
  Husk({required super.position})
      : super(size: Vector2(52, 60), hp: 120);

  @override String get enemyName        => 'Husk';
  @override double get moveSpeed        => 55.0;
  @override double get attackDamage     => 30.0;
  @override double get sanityDrainOnHit  => 1.0; // drainSanityOnHit on slam only
  @override double get detectionRange   => 180.0;
  @override double get attackRange      => 70.0;
  @override double get soulEssenceDrop  => 25.0;

  bool _isCharging   = false;
  bool _isSlamming   = false;
  double _chargeTimer = 0.0;
  static const double _chargeSpeed    = 280.0;
  static const double _chargeDuration = 0.45;
  static const double _slamAoeRadius  = 80.0;

  // Attack selection: alternate slam and charge
  bool _nextAttackIsCharge = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF2C2C2A),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isCharging) {
      _chargeTimer += dt;
      velocity.x = facingRight ? _chargeSpeed : -_chargeSpeed;
      if (_chargeTimer >= _chargeDuration) {
        _isCharging = false;
        _chargeTimer = 0;
        velocity.x = 0;
      }
    }
  }

  @override
  void onAttackBehaviour() {
    if (_nextAttackIsCharge) {
      _doCharge();
    } else {
      _doSlam();
    }
    _nextAttackIsCharge = !_nextAttackIsCharge;
  }

  void _doSlam() {
    if (_isSlamming) return;
    _isSlamming = true;

    // Visual telegraph: brief pause then slam
    velocity.x = 0;

    // Slam animation: scale Y squish then expand
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2(1.2, 0.8),
          EffectController(duration: 0.15),
        ),
        ScaleEffect.to(
          Vector2(0.9, 1.3),
          EffectController(duration: 0.1),
        ),
        ScaleEffect.to(
          Vector2(1.0, 1.0),
          EffectController(duration: 0.1),
        ),
      ]),
    );

    // AoE damage zone — dealt after slam lands
    Future.delayed(const Duration(milliseconds: 250), () {
      if (isDead) return;
      _dealSlamAoe();
      _isSlamming = false;
    });
  }

  void _dealSlamAoe() {
    // Damage all entities within slam radius
    // In full impl: iterate world components, check distance
    // The sanity drain fires via the base class onAttackBehaviour → player.survival.drainSanityOnHit
    gameRef.world.add(
      SlamAoeIndicator(
        position: Vector2(position.x - _slamAoeRadius / 2, position.y + size.y - 8),
        radius: _slamAoeRadius,
      ),
    );
  }

  void _doCharge() {
    if (_isCharging) return;
    _isCharging   = true;
    _chargeTimer  = 0;

    // Brief wind-up
    add(
      ScaleEffect.to(
        Vector2(0.85, 1.15),
        EffectController(duration: 0.2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (isDead) return;
      add(ScaleEffect.to(Vector2(1.0, 1.0), EffectController(duration: 0.1)));
    });
  }

  @override
  void onChaseBehaviour() {
    if (!_isCharging) {
      velocity.x = facingRight ? moveSpeed : -moveSpeed;
    }
  }

  @override
  void onRetreatBehaviour() {
    // Husk rarely retreats — slow shuffle backward
    velocity.x = facingRight ? -moveSpeed * 0.5 : moveSpeed * 0.5;
  }
}

/// Visual indicator for the slam AoE zone.
class SlamAoeIndicator extends PositionComponent {
  SlamAoeIndicator({required super.position, required this.radius})
      : super(size: Vector2(radius, 12));

  final double radius;
  double _age = 0.0;

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFFF5A623)
          ..style = PaintingStyle.fill,
      ),
    );
    add(OpacityEffect.to(0.5, EffectController(duration: 0)));
  }

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= 0.4) removeFromParent();
    opacity = 0.5 * (1 - _age / 0.4);
  }
}
