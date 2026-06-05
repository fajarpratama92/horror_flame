import 'package:flame/components.dart';
import 'base_enemy_component.dart';

/// Crawler — Tier 2 common enemy.
///
/// Clings to ceilings and walls. Drops on player from above.
/// HP: 25 | Damage: 12 | Speed: very fast | Sanity drain: none
/// Drop: 6 Soul Essence
class Crawler extends BaseEnemyComponent {
  Crawler({required super.position})
      : super(size: Vector2(32, 20), hp: 25);

  @override String get enemyName        => 'Crawler';
  @override double get moveSpeed        => 160.0;
  @override double get attackDamage     => 12.0;
  @override double get sanityDrainOnHit  => 0.0;
  @override double get detectionRange   => 220.0;
  @override double get attackRange      => 40.0;
  @override double get soulEssenceDrop  => 6.0;

  // Crawler-specific state
  bool _isClinging = false;  // attached to ceiling/wall
  bool _isDropping = false;  // mid drop-attack
  double _clingTimer = 0.0;
  static const double _dropStunDuration = 0.4; // stun on landing

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Crawlers start clung to ceiling — override Y position
    _isClinging = true;
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF3D2E08),
      ),
    );
  }

  @override
  void update(double dt) {
    _clingTimer += dt;

    if (_isClinging) {
      // No physics while clinging
      velocity.x = 0;
      velocity.y = 0;
      _updateClingBehaviour(dt);
    } else if (_isDropping) {
      // Free-fall during drop attack
      super.update(dt);
    } else {
      super.update(dt);
    }
  }

  void _updateClingBehaviour(double dt) {
    // Move horizontally toward player while on ceiling
    // Flip to drop-attack when directly above player
    if (_clingTimer > 0.5) {
      _clingTimer = 0;
      final playerBelow = _isPlayerBelow();
      if (playerBelow && ai.distanceToPlayer < attackRange * 2) {
        _triggerDropAttack();
      }
    }
  }

  bool _isPlayerBelow() {
    // Check if player is directly beneath (within X tolerance)
    // In full impl: query world for player position
    return ai.distanceToPlayer < 80.0;
  }

  void _triggerDropAttack() {
    _isClinging = false;
    _isDropping = true;
    velocity.y = 200.0; // Fast drop
  }

  @override
  void onLanded() {
    if (_isDropping) {
      _isDropping = false;
      // Deal damage to player if in range (handled by attackBehaviour)
      // Brief stun on land — visual shake
      Future.delayed(
        Duration(milliseconds: (_dropStunDuration * 1000).toInt()),
        () => _isClinging = true,
      );
    }
  }

  @override
  void onAttackBehaviour() {
    _triggerDropAttack();
  }

  @override
  void onPatrolBehaviour() {
    // Crawl along ceiling horizontally
    velocity.x = facingRight ? moveSpeed * 0.4 : -moveSpeed * 0.4;
  }

  @override
  void onChaseBehaviour() {
    // Speed up horizontal ceiling movement toward player
    velocity.x = facingRight ? moveSpeed * 0.8 : -moveSpeed * 0.8;
  }
}
