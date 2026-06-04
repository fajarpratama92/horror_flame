import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../utils/constants.dart';

/// Mixin that adds platformer physics to any PositionComponent.
///
/// Handles:
/// - Gravity accumulation
/// - Terminal velocity
/// - Ground detection via collision
/// - One-way platform support
mixin PhysicsBody on PositionComponent, CollisionCallbacks {
  final Vector2 velocity = Vector2.zero();

  bool isOnGround   = false;
  bool isTouchingWallLeft  = false;
  bool isTouchingWallRight = false;
  bool _wasOnGround = false;

  /// Called the first frame the entity lands on the ground.
  void onLanded() {}

  /// Called the first frame the entity leaves the ground.
  void onLeftGround() {}

  void updatePhysics(double dt) {
    _wasOnGround = isOnGround;

    // Apply gravity when airborne
    if (!isOnGround) {
      velocity.y =
          (velocity.y + GameConstants.gravity * dt).clamp(
            -double.infinity, GameConstants.maxFallSpeed);
    }

    // Move
    position += velocity * dt;

    // Landing / leaving ground callbacks
    if (!_wasOnGround && isOnGround) onLanded();
    if (_wasOnGround && !isOnGround) onLeftGround();
  }

  // ── Collision handling ────────────────────────────────────
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlatformHitbox) {
      _resolveGroundCollision(other, intersectionPoints);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is PlatformHitbox) {
      isOnGround = false;
      isTouchingWallLeft  = false;
      isTouchingWallRight = false;
    }
  }

  void _resolveGroundCollision(
      PlatformHitbox platform, Set<Vector2> points) {
    if (points.isEmpty) return;

    // Find collision normal by checking penetration direction
    final entityBottom = position.y + size.y;
    final platformTop  = platform.absolutePosition.y;

    final entityRight  = position.x + size.x;
    final platformLeft = platform.absolutePosition.x;

    final entityLeft    = position.x;
    final platformRight = platform.absolutePosition.x + platform.size.x;

    final penetrationBottom = entityBottom - platformTop;
    final penetrationLeft   = platformRight - entityLeft;
    final penetrationRight  = entityRight - platformLeft;

    final minPen = [penetrationBottom, penetrationLeft, penetrationRight]
        .reduce((a, b) => a < b ? a : b);

    if (minPen == penetrationBottom && velocity.y >= 0) {
      // Landing on top
      position.y = platformTop - size.y;
      velocity.y = 0;
      isOnGround = true;
    } else if (minPen == penetrationLeft) {
      position.x = platformRight;
      velocity.x = 0;
      isTouchingWallLeft = true;
    } else if (minPen == penetrationRight) {
      position.x = platformLeft - size.x;
      velocity.x = 0;
      isTouchingWallRight = true;
    }
  }
}

/// Hitbox component placed on static platform tiles.
class PlatformHitbox extends RectangleHitbox {
  PlatformHitbox({super.size, super.position})
      : super(collisionType: CollisionType.passive);
}
