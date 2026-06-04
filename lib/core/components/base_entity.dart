import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

/// Base class for all game entities (player, enemies, props).
///
/// Provides:
/// - Position, size, velocity
/// - Collision detection mixin
/// - Health tracking
/// - Direction (facing left/right)
abstract class BaseEntity extends PositionComponent
    with HasGameRef, CollisionCallbacks {
  BaseEntity({
    required Vector2 position,
    required Vector2 size,
    this.maxHealth = 100.0,
  }) : super(position: position, size: size) {
    health = maxHealth;
  }

  // ── Health ────────────────────────────────────────────────
  final double maxHealth;
  late double health;
  bool get isAlive => health > 0;
  bool get isDead  => !isAlive;

  // ── Direction ─────────────────────────────────────────────
  bool facingRight = true;

  // ── Physics ───────────────────────────────────────────────
  Vector2 velocity = Vector2.zero();
  bool isOnGround  = false;

  // ── Damage ────────────────────────────────────────────────
  /// Apply damage to this entity. Returns true if entity died.
  bool takeDamage(double amount) {
    health = (health - amount).clamp(0.0, maxHealth);
    onDamageTaken(amount);
    if (isDead) {
      onDeath();
      return true;
    }
    return false;
  }

  void heal(double amount) {
    health = (health + amount).clamp(0.0, maxHealth);
  }

  // ── Overridable hooks ─────────────────────────────────────
  void onDamageTaken(double amount) {}
  void onDeath() { removeFromParent(); }
}
