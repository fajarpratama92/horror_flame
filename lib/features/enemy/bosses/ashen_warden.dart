import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../base_enemy_component.dart';
import 'package:flutter/material.dart';

/// Ashen Warden — Chapter 1 Boss.
///
/// HP: 500 | 2 phases | Sanity drain: −3/s in arena
/// Phase 1 (100–50%): Melee combo, ground slam, shield bash
/// Phase 2 (<50%): Veil energy activated — projectile spread, Sanity drain on every hit
/// Drop: 100 Soul Essence + skill unlock + Sanity +20
class AshenWarden extends BaseEnemyComponent {
  AshenWarden({required super.position})
      : super(size: Vector2(64, 80), hp: 500);

  @override String get enemyName        => 'Ashen Warden';
  @override double get moveSpeed        => 70.0;
  @override double get attackDamage     => 35.0;
  @override double get sanityDrainOnHit  => 0.0; // Phase 1: no sanity drain
  @override double get detectionRange   => 400.0; // Always aggro in boss room
  @override double get attackRange      => 80.0;
  @override double get soulEssenceDrop  => 100.0;

  // Phase tracking
  BossPhase _phase = BossPhase.phase1;
  bool _phaseTransitioning = false;

  // Attack rotation
  int _attackIndex = 0;
  static const List<_WardenAttack> _phase1Attacks = [
    _WardenAttack.meleeCombo,
    _WardenAttack.groundSlam,
    _WardenAttack.shieldBash,
    _WardenAttack.meleeCombo,
  ];
  static const List<_WardenAttack> _phase2Attacks = [
    _WardenAttack.veilProjectile,
    _WardenAttack.meleeCombo,
    _WardenAttack.groundSlam,
    _WardenAttack.veilProjectile,
    _WardenAttack.shieldBash,
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Large boss visuals — placeholder
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF3D2E08),
      ),
    );
    // Phase indicator bar drawn via BossHudOverlay — not here
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check phase transition
    if (_phase == BossPhase.phase1 &&
        health / maxHealth < 0.5 &&
        !_phaseTransitioning) {
      _triggerPhaseTransition();
    }
  }

  void _triggerPhaseTransition() {
    _phaseTransitioning = true;
    velocity.x = 0;

    // Camera shake + flash
    gameRef.camera.viewfinder.add(
      MoveEffect.by(
        Vector2(0, 0),
        EffectController(
          duration: 0.6,
          curve: Curves.elasticOut,
        ),
      ),
    );

    // Visual: brief white flash then ash-particle burst
    add(
      SequenceEffect([
        OpacityEffect.to(0.3, EffectController(duration: 0.1)),
        OpacityEffect.to(1.0, EffectController(duration: 0.1)),
        OpacityEffect.to(0.3, EffectController(duration: 0.1)),
        OpacityEffect.to(1.0, EffectController(duration: 0.1)),
      ]),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      _phase = BossPhase.phase2;
      _phaseTransitioning = false;
      _attackIndex = 0;
      // Phase 2: all attacks gain Sanity drain
      // Set sanity drain flag — handled in onAttackBehaviour override
    });
  }

  @override
  void onAttackBehaviour() {
    final attacks = _phase == BossPhase.phase1 ? _phase1Attacks : _phase2Attacks;
    final attack  = attacks[_attackIndex % attacks.length];
    _attackIndex++;

    switch (attack) {
      case _WardenAttack.meleeCombo:
        _doMeleeCombo();
      case _WardenAttack.groundSlam:
        _doGroundSlam();
      case _WardenAttack.shieldBash:
        _doShieldBash();
      case _WardenAttack.veilProjectile:
        _doVeilProjectileSpread();
    }
  }

  void _doMeleeCombo() {
    // 3-hit melee combo with slight forward movement each hit
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (isDead) return;
        final dmg = _phase == BossPhase.phase2 ? attackDamage * 1.2 : attackDamage;
        // Deal damage to player in melee range (handled by collision)
        velocity.x = facingRight ? 60.0 : -60.0;
        Future.delayed(const Duration(milliseconds: 100), () => velocity.x = 0);
      });
    }
  }

  void _doGroundSlam() {
    // Signature move: leap + crash + AoE shockwave
    velocity.y = -300.0; // brief leap
    Future.delayed(const Duration(milliseconds: 350), () {
      if (isDead) return;
      velocity.y = 400.0; // crash down
      Future.delayed(const Duration(milliseconds: 150), () {
        if (isDead) return;
        // AoE shockwave — radius 120px, damage 25
        if (_phase == BossPhase.phase2) {
          // Phase 2: also drains Sanity
          // player.survival.drainSanityOnHit() called via collision
        }
      });
    });
  }

  void _doShieldBash() {
    // Charge forward with shield
    velocity.x = facingRight ? 200.0 : -200.0;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (isDead) return;
      velocity.x = 0;
    });
  }

  void _doVeilProjectileSpread() {
    // Phase 2 only: 5-projectile spread fan
    assert(_phase == BossPhase.phase2);
    final angles = [-0.4, -0.2, 0.0, 0.2, 0.4];
    for (final angle in angles) {
      final baseDir = facingRight ? Vector2(1, 0) : Vector2(-1, 0);
      final dir = Vector2(
        baseDir.x * cos(angle) - baseDir.y * sin(angle),
        baseDir.x * sin(angle) + baseDir.y * cos(angle),
      );
      gameRef.world.add(
        WardenVeilBolt(
          position: center.clone(),
          direction: dir,
          damage: 18.0,
          drainsSanity: true,
        ),
      );
    }
  }

  // Simple cos/sin approximations for the spread pattern
  static double cos(double x) {
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24;
  }

  static double sin(double x) {
    final x3 = x * x * x;
    return x - x3 / 6 + x3 * x * x / 120;
  }

  @override
  void onDeathBehaviour() {
    // Trigger chapter clear
    Future.delayed(const Duration(milliseconds: 1200), () {
      gameRef.overlays.add('ChapterClear');
    });
  }
}

enum BossPhase { phase1, phase2, phase3 }

enum _WardenAttack { meleeCombo, groundSlam, shieldBash, veilProjectile }

/// Amber Veil bolt projectile (Phase 2 Ashen Warden).
class WardenVeilBolt extends PositionComponent {
  WardenVeilBolt({
    required super.position,
    required this.direction,
    required this.damage,
    this.drainsSanity = false,
  }) : super(size: Vector2(14, 14));

  final Vector2 direction;
  final double  damage;
  final bool    drainsSanity;
  double _age = 0.0;

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFFEF9F27),
    ));
  }

  @override
  void update(double dt) {
    _age += dt;
    if (_age > 1.8) { removeFromParent(); return; }
    position += direction * 220 * dt;
  }
}
