import 'dart:typed_data';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../../core/components/base_entity.dart';
import '../../core/game/veilborn_game.dart';
import '../../core/components/physics_body.dart';
import '../../core/utils/constants.dart';
import '../survival/survival_controller.dart';

/// The player character — full implementation.
///
/// Integrates: physics, sprite animation, melee hitboxes, combo system,
/// i-frames, and survival resource callbacks.
class PlayerComponent extends BaseEntity
    with PhysicsBody, CollisionCallbacks {
  PlayerComponent({required super.position})
      : super(
          size: Vector2(32, 48),
          maxHealth: GameConstants.playerBaseHealth,
        );

  // ── Sub-components ────────────────────────────────────────
  late final SurvivalController survival;
  late final RectangleHitbox    _bodyHitbox;
  RectangleHitbox? _attackHitbox;

  // ── Animation ─────────────────────────────────────────────
  late final SpriteAnimationGroupComponent<PlayerState> _anim;
  PlayerState _state = PlayerState.idle;

  // ── Movement state ────────────────────────────────────────
  double _coyoteTimer  = 0.0;
  double _jumpBuffer   = 0.0;
  double _dashTimer    = 0.0;
  double _iFrameTimer  = 0.0;
  bool   _isDashing    = false;
  bool   _wallSliding  = false;

  bool get isInvincible => _iFrameTimer > 0;
  bool get _inCoyoteWindow =>
      _coyoteTimer <= GameConstants.coyoteTimeDuration;

  // ── Combo state ───────────────────────────────────────────
  int    _comboCount = 0;
  double _comboTimer = 0.0;
  bool   _isAttacking = false;

  // ── Callbacks ─────────────────────────────────────────────
  /// Emitted when player deals damage (enemy listens)
  void Function(double damage, Vector2 at)? onDealDamage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Survival
    survival = SurvivalController();
    survival.onDeath = _onPlayerDeath;
    survival.onSanityThresholdCrossed = _onSanityThreshold;
    add(survival);

    // Body hitbox (passive — enemies detect player, not attack)
    _bodyHitbox = RectangleHitbox(
      size: Vector2(28, 44),
      position: Vector2(2, 4),
      collisionType: CollisionType.active,
    );
    add(_bodyHitbox);

    // Sprite animation group
    _anim = SpriteAnimationGroupComponent<PlayerState>(
      animations: await _buildAnimations(),
      current: PlayerState.idle,
      size: size,
    );
    add(_anim);

    // Anchor to bottom-centre for intuitive position handling
    anchor = Anchor.bottomCenter;
  }

  @override
  void update(double dt) {
    super.update(dt);
    updatePhysics(dt);         // PhysicsBody mixin
    _updateTimers(dt);
    _updateWallSlide();
    _updateAnimationState();
  }

  // ── Timers ────────────────────────────────────────────────
  void _updateTimers(double dt) {
    if (_coyoteTimer < double.infinity) _coyoteTimer += dt;
    if (_jumpBuffer > 0)  _jumpBuffer  -= dt;
    if (_iFrameTimer > 0) _iFrameTimer -= dt;
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) _comboCount = 0;
    }
    if (_isDashing) {
      _dashTimer -= dt;
      if (_dashTimer <= 0) {
        _isDashing = false;
        velocity.x = 0;
      }
    }
  }

  // ── Wall slide ────────────────────────────────────────────
  void _updateWallSlide() {
    _wallSliding = !isOnGround &&
        (isTouchingWallLeft || isTouchingWallRight) &&
        velocity.y > 0;
    if (_wallSliding) {
      velocity.y = velocity.y.clamp(0, 80.0); // slow slide
    }
  }

  // ── Animation state machine ───────────────────────────────
  void _updateAnimationState() {
    final next = _resolveState();
    if (next != _state) {
      _state = next;
      _anim.current = next;
    }
  }

  PlayerState _resolveState() {
    if (_isAttacking)   return PlayerState.attack;
    if (_isDashing)     return PlayerState.dash;
    if (_wallSliding)   return PlayerState.wallSlide;
    if (!isOnGround)    return velocity.y < 0 ? PlayerState.jump : PlayerState.fall;
    if (velocity.x.abs() > 10) return PlayerState.run;
    return PlayerState.idle;
  }

  // ── Physics callbacks ────────────────────────────────────
  @override
  void onLanded() {
    if (_jumpBuffer > 0) {
      _jumpBuffer = 0;
      _doJump();
    }
  }

  @override
  void onLeftGround() {
    _coyoteTimer = 0.0;
  }

  // ── Movement API ─────────────────────────────────────────
  void moveLeft() {
    if (_isDashing) return;
    facingRight = false;
    velocity.x = -GameConstants.playerMoveSpeed;
    scale.x = -1; // flip sprite
  }

  void moveRight() {
    if (_isDashing) return;
    facingRight = true;
    velocity.x = GameConstants.playerMoveSpeed;
    scale.x = 1;
  }

  void stopMove() {
    if (!_isDashing) velocity.x = 0;
  }

  void jump() {
    if (isOnGround || _inCoyoteWindow) {
      _doJump();
    } else if (_wallSliding) {
      _doWallJump();
    } else {
      _jumpBuffer = GameConstants.jumpBufferDuration;
    }
  }

  void _doJump() {
    velocity.y = GameConstants.playerJumpForce;
    isOnGround  = false;
    _coyoteTimer = double.infinity;
  }

  void _doWallJump() {
    velocity.y = GameConstants.playerJumpForce;
    velocity.x = facingRight
        ? -GameConstants.playerMoveSpeed
        :  GameConstants.playerMoveSpeed;
    facingRight = !facingRight;
    scale.x = facingRight ? 1 : -1;
    survival.consumeStamina(10.0);
  }

  void dash() {
    if (_isDashing || !survival.canDash) return;
    survival.consumeStamina(GameConstants.staminaDashCost);
    _isDashing   = true;
    _dashTimer   = GameConstants.playerDashDuration;
    _iFrameTimer = GameConstants.playerIFrameDuration;
    velocity.y   = 0;
    velocity.x   = facingRight
        ?  GameConstants.playerDashForce
        : -GameConstants.playerDashForce;
    _flashInvincibility();
  }

  // ── Combat API ────────────────────────────────────────────
  void lightAttack() {
    if (_isAttacking) return;
    _comboTimer = GameConstants.comboWindowDuration;
    _comboCount++;

    if (_comboCount >= GameConstants.comboLightCount) {
      _executeComboFinisher();
    } else {
      _executeAttack(
        damage: GameConstants.lightAttackDamage,
        duration: 0.25,
        hitboxOffset: facingRight ? Vector2(size.x, 8) : Vector2(-28, 8),
        hitboxSize: Vector2(28, 24),
      );
    }
  }

  void heavyAttack() {
    if (_isAttacking) return;
    if (!survival.consumeStamina(GameConstants.staminaHeavyCost)) return;
    _comboCount = 0;
    _executeAttack(
      damage: GameConstants.heavyAttackDamage,
      duration: 0.45,
      hitboxOffset: facingRight ? Vector2(size.x, 4) : Vector2(-36, 4),
      hitboxSize: Vector2(36, 36),
      knockback: true,
    );
  }

  void rangedAttack() {
    if (!survival.consumeStamina(GameConstants.staminaRangedCost)) return;
    // Spawn projectile — delegated to parent world
    final dir = facingRight ? Vector2(1, 0) : Vector2(-1, 0);
    gameRef.world.add(
      PlayerProjectile(
        position: position + Vector2(facingRight ? size.x : 0, size.y / 2),
        direction: dir,
        damage: GameConstants.rangedAttackDamage,
      ),
    );
  }

  void _executeComboFinisher() {
    _comboCount = 0;
    _executeAttack(
      damage: GameConstants.comboFinisherDamage,
      duration: 0.35,
      hitboxOffset: Vector2(-16, 0),
      hitboxSize: Vector2(size.x + 32, size.y), // AoE
      knockback: true,
    );
  }

  void _executeAttack({
    required double damage,
    required double duration,
    required Vector2 hitboxOffset,
    required Vector2 hitboxSize,
    bool knockback = false,
  }) {
    _isAttacking = true;

    // Active attack hitbox
    _attackHitbox = RectangleHitbox(
      size: hitboxSize,
      position: hitboxOffset,
      collisionType: CollisionType.active,
    )..isSolid = false;
    add(_attackHitbox!);

    // Remove hitbox after active frames
    Future.delayed(
      Duration(milliseconds: (duration * 1000).toInt()),
      () {
        _attackHitbox?.removeFromParent();
        _attackHitbox  = null;
        _isAttacking   = false;
      },
    );

    // Broadcast damage to overlapping enemies
    onDealDamage?.call(damage, position);
  }

  // ── Damage received ───────────────────────────────────────
  @override
  void onDamageTaken(double amount) {
    if (isInvincible) return;
    survival.takeDamage(amount);
    _iFrameTimer = GameConstants.playerIFrameDuration;
    _flashHitEffect();
  }

  // ── Visual effects ────────────────────────────────────────
  void _flashHitEffect() {
    add(
      SequenceEffect([
        OpacityEffect.to(0.3, EffectController(duration: 0.08)),
        OpacityEffect.to(1.0, EffectController(duration: 0.08)),
        OpacityEffect.to(0.3, EffectController(duration: 0.08)),
        OpacityEffect.to(1.0, EffectController(duration: 0.08)),
      ]),
    );
  }

  void _flashInvincibility() {
    add(
      SequenceEffect(
        List.generate(
          4,
          (_) => SequenceEffect([
            OpacityEffect.to(0.4, EffectController(duration: 0.04)),
            OpacityEffect.to(1.0, EffectController(duration: 0.04)),
          ]),
        ),
      ),
    );
  }

  // ── Sanity effects ────────────────────────────────────────
  void _onSanityThreshold(SanityThreshold threshold) {
    // Delegate visual distortion to SanityEffectsOverlay
    gameRef.camera.viewfinder.add(
      SanityShakeEffect(threshold: threshold),
    );
  }

  // ── Death ─────────────────────────────────────────────────
  void _onPlayerDeath() {
    add(
      SequenceEffect([
        OpacityEffect.to(0.0, EffectController(duration: 0.6)),
        RemoveEffect(),
      ]),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      (gameRef as VeilbornGame).gameOver();
    });
  }

  // ── Animations builder ───────────────────────────────────
  Future<Map<PlayerState, SpriteAnimation>> _buildAnimations() async {
    // TODO: replace with real sprite sheets from assets/images/player/
    // Placeholder: single-frame colour rectangle per state
    final placeholder = await gameRef.images.fromPixels(
      Uint32List.fromList([0xFF6B3FA0]), 1, 1); // Veil purple

    SpriteAnimation single() => SpriteAnimation.spriteList(
      [Sprite(placeholder)], stepTime: 1.0);

    return {
      PlayerState.idle:      single(),
      PlayerState.run:       single(),
      PlayerState.jump:      single(),
      PlayerState.fall:      single(),
      PlayerState.dash:      single(),
      PlayerState.attack:    single(),
      PlayerState.wallSlide: single(),
      PlayerState.death:     single(),
    };
  }
}

// ── Player state enum ─────────────────────────────────────
enum PlayerState { idle, run, jump, fall, dash, attack, wallSlide, death }

// ── Ranged projectile ────────────────────────────────────
class PlayerProjectile extends PositionComponent with CollisionCallbacks {
  PlayerProjectile({
    required super.position,
    required this.direction,
    required this.damage,
  }) : super(size: Vector2(12, 8));

  final Vector2 direction;
  final double  damage;
  static const double _speed  = 400.0;
  static const double _maxAge = 1.2; // seconds
  double _age = 0.0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _maxAge) { removeFromParent(); return; }
    position += direction * _speed * dt;
  }
}

// ── Sanity camera shake effect ────────────────────────────
class SanityShakeEffect extends Effect {
  SanityShakeEffect({required this.threshold})
      : super(EffectController(duration: 0.4));

  final SanityThreshold threshold;

  @override
  void apply(double progress) {
    // Handled by SanityEffectsOverlay — this is a signal only
  }
}
