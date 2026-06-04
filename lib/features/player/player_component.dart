import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../core/components/base_entity.dart';
import '../../core/utils/constants.dart';
import '../survival/survival_controller.dart';

/// The player character Flame component.
///
/// Responsibilities:
/// - Platformer physics (gravity, jump, dash, wall-jump)
/// - Combat input delegation
/// - Survival resource integration
/// - Animation state management
class PlayerComponent extends BaseEntity {
  PlayerComponent({required super.position})
      : super(size: Vector2(32, 48), maxHealth: GameConstants.playerBaseHealth);

  // ── Sub-components ────────────────────────────────────────
  late final SurvivalController survival;
  late final RectangleHitbox _hitbox;

  // ── Movement state ────────────────────────────────────────
  bool _isJumping       = false;
  bool _isDashing       = false;
  bool _isTouchingWall  = false;
  double _coyoteTimer   = 0.0;
  double _jumpBuffer    = 0.0;
  double _dashTimer     = 0.0;
  double _iFrameTimer   = 0.0;
  bool get isInvincible => _iFrameTimer > 0;

  // ── Combo state ───────────────────────────────────────────
  int    _comboCount    = 0;
  double _comboTimer    = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Survival controller
    survival = SurvivalController();
    survival.onDeath = _onPlayerDeath;
    add(survival);

    // Hitbox
    _hitbox = RectangleHitbox(
      size: Vector2(28, 44),
      position: Vector2(2, 4), // slight inset for forgiving collision
    );
    add(_hitbox);

    // TODO Phase 5: Add sprite animation
    // add(SpriteAnimationComponent(...));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _applyGravity(dt);
    _updateCoyoteTime(dt);
    _updateJumpBuffer(dt);
    _updateDash(dt);
    _updateIFrames(dt);
    _updateCombo(dt);
    _applyVelocity(dt);
  }

  // ── Physics ───────────────────────────────────────────────
  void _applyGravity(double dt) {
    if (!isOnGround && !_isDashing) {
      velocity.y += GameConstants.gravity * dt;
      velocity.y = velocity.y.clamp(
          -double.infinity, GameConstants.maxFallSpeed);
    }
  }

  void _applyVelocity(double dt) {
    position += velocity * dt;
    // TODO: resolve collisions against tile map
  }

  void _updateCoyoteTime(double dt) {
    if (!isOnGround) {
      _coyoteTimer += dt;
    } else {
      _coyoteTimer = 0.0;
    }
  }

  bool get _inCoyoteWindow =>
      _coyoteTimer <= GameConstants.coyoteTimeDuration;

  void _updateJumpBuffer(double dt) {
    if (_jumpBuffer > 0) _jumpBuffer -= dt;
  }

  void _updateDash(double dt) {
    if (_isDashing) {
      _dashTimer -= dt;
      if (_dashTimer <= 0) {
        _isDashing = false;
        velocity.x = 0;
      }
    }
  }

  void _updateIFrames(double dt) {
    if (_iFrameTimer > 0) _iFrameTimer -= dt;
  }

  void _updateCombo(double dt) {
    if (_comboCount > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) _comboCount = 0;
    }
  }

  // ── Input handlers (called by input controller) ───────────
  void moveLeft()  { if (!_isDashing) velocity.x = -GameConstants.playerMoveSpeed; facingRight = false; }
  void moveRight() { if (!_isDashing) velocity.x =  GameConstants.playerMoveSpeed; facingRight = true;  }
  void stopMove()  { if (!_isDashing) velocity.x = 0; }

  void jump() {
    if (isOnGround || _inCoyoteWindow) {
      _doJump();
    } else {
      _jumpBuffer = GameConstants.jumpBufferDuration;
    }
  }

  void _doJump() {
    velocity.y = GameConstants.playerJumpForce;
    isOnGround = false;
    _isJumping = true;
    _coyoteTimer = double.infinity; // consume coyote time
  }

  void dash() {
    if (!survival.canDash) return;
    if (_isDashing) return;
    survival.consumeStamina(GameConstants.staminaDashCost);
    _isDashing = true;
    _dashTimer = GameConstants.playerDashDuration;
    _iFrameTimer = GameConstants.playerIFrameDuration;
    velocity.x = facingRight
        ? GameConstants.playerDashForce
        : -GameConstants.playerDashForce;
  }

  void wallJump() {
    if (!_isTouchingWall) return;
    velocity.y = GameConstants.playerJumpForce;
    velocity.x = facingRight
        ? -GameConstants.playerMoveSpeed
        : GameConstants.playerMoveSpeed;
    facingRight = !facingRight;
    survival.consumeStamina(10.0);
  }

  // ── Combat ────────────────────────────────────────────────
  void lightAttack() {
    _comboTimer = GameConstants.comboWindowDuration;
    _comboCount++;

    if (_comboCount >= GameConstants.comboLightCount) {
      _triggerComboFinisher();
    } else {
      // TODO Phase 5: activate light attack hitbox for N frames
      // damage = GameConstants.lightAttackDamage
    }
  }

  void heavyAttack() {
    if (!survival.consumeStamina(GameConstants.staminaHeavyCost)) return;
    _comboCount = 0;
    // TODO Phase 5: activate heavy attack hitbox
    // damage = GameConstants.heavyAttackDamage, knockback
  }

  void rangedAttack() {
    if (!survival.consumeStamina(GameConstants.staminaRangedCost)) return;
    // TODO Phase 5: spawn projectile component
    // damage = GameConstants.rangedAttackDamage
  }

  void _triggerComboFinisher() {
    _comboCount = 0;
    // TODO Phase 5: activate finisher hitbox (AoE)
    // damage = GameConstants.comboFinisherDamage
  }

  // ── Damage received ───────────────────────────────────────
  @override
  void onDamageTaken(double amount) {
    if (isInvincible) return; // absorbed by i-frames
    survival.takeDamage(amount);
    _iFrameTimer = GameConstants.playerIFrameDuration;
    // TODO Phase 5: play hit animation, flash sprite
  }

  // ── Death ─────────────────────────────────────────────────
  void _onPlayerDeath() {
    // TODO Phase 5: play death animation, then trigger game over
    gameRef.gameOver();
  }

  // ── Landing ───────────────────────────────────────────────
  void onLand() {
    isOnGround = true;
    _isJumping = false;
    velocity.y = 0;

    // Consume buffered jump if present
    if (_jumpBuffer > 0) {
      _jumpBuffer = 0;
      _doJump();
    }
  }
}
