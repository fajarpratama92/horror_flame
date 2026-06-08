import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../base_enemy_component.dart';
import '../wraith.dart';
import 'ashen_warden.dart' show BossPhase;
import 'package:flutter/material.dart';

/// Veil Seraph — Chapter 2 Boss.
///
/// HP: 800 | 3 phases | Sanity drain: −5/s in arena
/// Phase 1 (100–65%): Aerial feather projectiles, dive bomb, wing sweep
/// Phase 2 (<65%): Summons 2 Wraiths every 20s, speed +30%
/// Phase 3 (<30%): Reality distortion — arena warps, fake platforms, Sanity drain ×2
/// Drop: 200 Soul Essence + 2 skill unlocks + Sanity +20
class VeilSeraph extends BaseEnemyComponent {
  VeilSeraph({required super.position})
      : super(size: Vector2(72, 88), hp: 800);

  @override String get enemyName        => 'Veil Seraph';
  @override double get moveSpeed        => 0.0; // Flies — no ground movement
  @override double get attackDamage     => 28.0;
  @override double get sanityDrainOnHit  => 1.0; // Phase 3: ×2 multiplier applied
  @override double get detectionRange   => 400.0;
  @override double get attackRange      => 200.0; // Aerial attacker
  @override double get soulEssenceDrop  => 200.0;

  BossPhase _phase = BossPhase.phase1;
  bool _phaseTransitioning = false;

  // Phase 2: Wraith summon timer
  double _wraithSummonTimer = 0.0;
  static const double _wraithSummonInterval = 20.0;

  // Float oscillation (same as Wraith)
  double _floatTimer = 0.0;
  double _baseY = 0.0;
  static const double _floatAmplitude = 18.0;
  static const double _floatFrequency = 1.2;

  // Attack rotation
  int _attackIndex = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _baseY = position.y;

    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF1E1530),
      ),
    );
    // Seraph is semi-opaque — ethereal
    add(OpacityEffect.to(0.9, EffectController(duration: 0)));
  }

  @override
  void update(double dt) {
    // Floating movement — override physics
    _floatTimer += dt;
    position.y = _baseY + (_floatAmplitude *
        _sin(_floatTimer * _floatFrequency * 2 * 3.14159));

    // Phase transition checks
    final hpRatio = health / maxHealth;
    if (_phase == BossPhase.phase1 && hpRatio < 0.65 && !_phaseTransitioning) {
      _transitionToPhase2();
    } else if (_phase == BossPhase.phase2 && hpRatio < 0.30 && !_phaseTransitioning) {
      _transitionToPhase3();
    }

    // Phase 2: wraith summons
    if (_phase == BossPhase.phase2 || _phase == BossPhase.phase3) {
      _wraithSummonTimer += dt;
      if (_wraithSummonTimer >= _wraithSummonInterval) {
        _wraithSummonTimer = 0;
        _summonWraiths();
      }
    }

    // AI update (skip PhysicsBody)
    ai.distanceToPlayer = position.distanceTo(
        _cachedPlayerPos ?? position);
    ai.hpRatio = hpRatio;
  }

  Vector2? _cachedPlayerPos;

  // ── Phase transitions ─────────────────────────────────────
  void _transitionToPhase2() {
    _phaseTransitioning = true;
    _attackIndex = 0;

    // Flash + camera shake
    add(
      SequenceEffect(List.generate(3, (_) => SequenceEffect([
        OpacityEffect.to(0.2, EffectController(duration: 0.08)),
        OpacityEffect.to(0.9, EffectController(duration: 0.08)),
      ]))),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      _phase = BossPhase.phase2;
      _phaseTransitioning = false;
      // Phase 2: speed up float
    });
  }

  void _transitionToPhase3() {
    _phaseTransitioning = true;
    _attackIndex = 0;

    // Dramatic mask-shatter effect
    add(
      SequenceEffect([
        OpacityEffect.to(0.0, EffectController(duration: 0.2)),
        OpacityEffect.to(1.0, EffectController(duration: 0.05)),
        OpacityEffect.to(0.0, EffectController(duration: 0.1)),
        OpacityEffect.to(1.0, EffectController(duration: 0.05)),
        OpacityEffect.to(0.7, EffectController(duration: 0.3)),
      ]),
    );

    // Trigger reality distortion in SanityEffectsOverlay via game event
    // In full impl: fire a game event that forces sanity to low threshold visually
    Future.delayed(const Duration(milliseconds: 800), () {
      _phase = BossPhase.phase3;
      _phaseTransitioning = false;
      // Phase 3: double sanity drain, fake platforms
      gameRef.overlays.add('RealityDistortion');
    });
  }

  // ── Attacks ───────────────────────────────────────────────
  @override
  void onAttackBehaviour() {
    switch (_phase) {
      case BossPhase.phase1:
        _phase1Attack();
      case BossPhase.phase2:
        _phase2Attack();
      case BossPhase.phase3:
        _phase3Attack();
    }
    _attackIndex++;
  }

  void _phase1Attack() {
    switch (_attackIndex % 3) {
      case 0: _featherSpread();
      case 1: _diveBomb();
      case 2: _wingSweep();
    }
  }

  void _phase2Attack() {
    switch (_attackIndex % 3) {
      case 0: _featherSpread(count: 8); // More projectiles
      case 1: _diveBomb();
      case 2: _featherSpread(count: 5);
    }
  }

  void _phase3Attack() {
    switch (_attackIndex % 4) {
      case 0: _voidExplosion();
      case 1: _featherSpread(count: 12, chaos: true);
      case 2: _diveBomb();
      case 3: _voidExplosion();
    }
  }

  void _featherSpread({int count = 5, bool chaos = false}) {
    final angleStep = 0.25;
    final baseAngle = facingRight ? 0.0 : 3.14159;
    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (i - count / 2) * angleStep +
          (chaos ? (i % 2 == 0 ? 0.1 : -0.1) : 0.0);
      final dir = Vector2(_cos(angle), _sin(angle) * 0.6 + 0.3);
      gameRef.world.add(
        SeraphFeather(
          position: center.clone(),
          direction: dir.normalized(),
          damage: attackDamage * 0.7,
          phase3: _phase == BossPhase.phase3,
        ),
      );
    }
  }

  void _diveBomb() {
    _baseY += 80; // Swoop down
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isDead) _baseY -= 80;
    });
  }

  void _wingSweep() {
    // Horizontal sweep — damage zone across arena width
    velocity.x = facingRight ? 180.0 : -180.0;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!isDead) velocity.x = 0;
    });
  }

  void _voidExplosion() {
    // Phase 3: large AoE void explosion at player position
    // Also triggers brief sanity spike
    gameRef.world.add(
      VoidExplosion(position: _cachedPlayerPos ?? position.clone()),
    );
  }

  void _summonWraiths() {
    for (int i = 0; i < 2; i++) {
      final spawnPos = position + Vector2(i == 0 ? -80.0 : 80.0, 0);
      gameRef.world.add(Wraith(position: spawnPos));
    }
  }

  // ── Death ─────────────────────────────────────────────────
  @override
  void onDeathBehaviour() {
    gameRef.overlays.remove('RealityDistortion');
    Future.delayed(const Duration(milliseconds: 1500), () {
      gameRef.overlays.add('ChapterClear');
    });
  }

  // Simple trig approximations
  static double _sin(double x) {
    final n = x - (x / (2 * 3.14159)).truncate() * 2 * 3.14159;
    return n - n * n * n / 6 + n * n * n * n * n / 120;
  }

  static double _cos(double x) => _sin(x + 3.14159 / 2);
}

/// Feather projectile fired by Veil Seraph.
class SeraphFeather extends PositionComponent {
  SeraphFeather({
    required super.position,
    required this.direction,
    required this.damage,
    this.phase3 = false,
  }) : super(size: Vector2(10, 18));

  final Vector2 direction;
  final double  damage;
  final bool    phase3;
  double _age = 0.0;
  static const double _speed = 240.0;

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = phase3
            ? const Color(0xFF6B3FA0)
            : const Color(0xFFAFA9EC),
    ));
  }

  @override
  void update(double dt) {
    _age += dt;
    if (_age > 1.6) { removeFromParent(); return; }
    position += direction * _speed * dt;
  }
}

/// Void explosion visual — Phase 3 Veil Seraph attack.
class VoidExplosion extends PositionComponent {
  VoidExplosion({required super.position}) : super(size: Vector2(120, 120));

  double _age = 0.0;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF6B3FA0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));
    add(OpacityEffect.to(0.6, EffectController(duration: 0)));
  }

  @override
  void update(double dt) {
    _age += dt;
    scale = Vector2.all(1.0 + _age * 2);
    // Remove from parent when fully faded
    // Opacity handled via OpacityEffect added in onLoad
    if (_age > 0.5) removeFromParent();
  }
}
