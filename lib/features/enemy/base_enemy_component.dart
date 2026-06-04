import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../../core/components/base_entity.dart';
import '../../core/components/physics_body.dart';
import '../player/player_component.dart';
import 'ai_state_machine.dart';

/// Base class for all Veilborn enemies.
///
/// Subclasses override:
/// - [enemyName], [maxHp], [moveSpeed], [attackDamage], [sanityDrainOnHit]
/// - [onPatrolBehaviour], [onChaseBehaviour], [onAttackBehaviour]
abstract class BaseEnemyComponent extends BaseEntity
    with PhysicsBody, CollisionCallbacks {
  BaseEnemyComponent({
    required super.position,
    required super.size,
    required double hp,
  }) : super(maxHealth: hp);

  // ── Subclass contract ─────────────────────────────────────
  String get enemyName;
  double get moveSpeed;
  double get attackDamage;
  double get sanityDrainOnHit;
  double get detectionRange;
  double get attackRange;
  double get soulEssenceDrop;

  // ── AI ────────────────────────────────────────────────────
  late final AiStateMachine _ai;

  // ── Player reference ──────────────────────────────────────
  PlayerComponent? _player;

  // ── Attack cooldown ───────────────────────────────────────
  bool _isAttacking = false;

  // ── Callbacks ─────────────────────────────────────────────
  void Function(double essence)? onDropEssence;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _ai = AiStateMachine(
      detectionRange: detectionRange,
      attackRange:    attackRange,
    );

    // Wire AI behaviour hooks
    _ai.onPatrol  = _patrolBehaviour;
    _ai.onChase   = _chaseBehaviour;
    _ai.onAttack  = _attackBehaviour;
    _ai.onRetreat = _retreatBehaviour;
    _ai.onDeath   = _deathBehaviour;
    add(_ai);

    // Body hitbox
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    updatePhysics(dt);

    // Feed AI distance + HP ratio each frame
    if (_player != null) {
      _ai.distanceToPlayer =
          (position - _player!.position).length;
    }
    _ai.hpRatio = health / maxHealth;
  }

  // ── Collision: detect player ──────────────────────────────
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      _player = other;
    }
  }

  // ── AI behaviour implementations ──────────────────────────
  void _patrolBehaviour() {
    // Walk back and forth — reverse direction at wall
    if (isTouchingWallLeft || isTouchingWallRight) {
      facingRight = !facingRight;
    }
    velocity.x = facingRight ? moveSpeed * 0.5 : -moveSpeed * 0.5;
    onPatrolBehaviour();
  }

  void _chaseBehaviour() {
    if (_player == null) return;
    final dir = (_player!.position.x - position.x);
    facingRight = dir > 0;
    velocity.x = facingRight ? moveSpeed : -moveSpeed;
    onChaseBehaviour();
  }

  void _attackBehaviour() {
    if (_player == null || _isAttacking) return;
    _isAttacking = true;

    // Deal damage to player
    _player!.takeDamage(attackDamage);

    // Apply sanity drain if applicable
    if (sanityDrainOnHit > 0) {
      _player!.survival.drainSanityOnHit();
    }

    onAttackBehaviour();

    // Reset attack flag after animation window
    Future.delayed(const Duration(milliseconds: 600), () {
      _isAttacking = false;
    });
  }

  void _retreatBehaviour() {
    if (_player == null) return;
    final dir = (_player!.position.x - position.x);
    // Move AWAY from player
    velocity.x = dir > 0 ? -moveSpeed : moveSpeed;
    onRetreatBehaviour();
  }

  void _deathBehaviour() {
    onDropEssence?.call(soulEssenceDrop);
    add(
      SequenceEffect([
        OpacityEffect.to(0.0, EffectController(duration: 0.5)),
        RemoveEffect(),
      ]),
    );
    onDeathBehaviour();
  }

  // ── Overridable hooks ─────────────────────────────────────
  void onPatrolBehaviour()  {}
  void onChaseBehaviour()   {}
  void onAttackBehaviour()  {}
  void onRetreatBehaviour() {}
  void onDeathBehaviour()   {}

  // ── Damage ────────────────────────────────────────────────
  @override
  void onDamageTaken(double amount) {
    _flashHitEffect();
    if (isDead) _ai.triggerDeath();
  }

  void _flashHitEffect() {
    add(
      SequenceEffect([
        OpacityEffect.to(0.3, EffectController(duration: 0.06)),
        OpacityEffect.to(1.0, EffectController(duration: 0.06)),
      ]),
    );
  }
}
