import 'package:flame/components.dart';

/// Generic AI state machine used by all Veilborn enemies.
///
/// States: Idle → Patrol → Chase → Attack → Cooldown → Retreat → Death
/// Each enemy type overrides the behaviour hooks for each state.
class AiStateMachine extends Component {
  AiStateMachine({
    this.detectionRange = 200.0,
    this.attackRange    = 60.0,
    this.retreatHpRatio = 0.2,
  });

  final double detectionRange;
  final double attackRange;
  final double retreatHpRatio; // Retreat when HP < this ratio

  EnemyAiState _state = EnemyAiState.patrol;
  EnemyAiState get state => _state;

  double _stateTimer    = 0.0;
  double _attackCooldown = 0.0;

  // ── Behaviour hooks (override in subclasses) ──────────────
  void Function()? onPatrol;
  void Function()? onChase;
  void Function()? onAttack;
  void Function()? onCooldown;
  void Function()? onRetreat;
  void Function()? onDeath;

  // ── External signals ──────────────────────────────────────
  double distanceToPlayer = double.infinity;
  double hpRatio          = 1.0; // current HP / max HP

  @override
  void update(double dt) {
    _stateTimer    += dt;
    _attackCooldown = (_attackCooldown - dt).clamp(0.0, double.infinity);
    _evaluate();
    _executeCurrent();
  }

  void _evaluate() {
    switch (_state) {
      case EnemyAiState.patrol:
        if (distanceToPlayer <= detectionRange) _transition(EnemyAiState.chase);
      case EnemyAiState.chase:
        if (distanceToPlayer <= attackRange && _attackCooldown == 0) {
          _transition(EnemyAiState.attack);
        } else if (distanceToPlayer > detectionRange * 1.5) {
          _transition(EnemyAiState.patrol);
        }
        if (hpRatio <= retreatHpRatio) _transition(EnemyAiState.retreat);
      case EnemyAiState.attack:
        // Attack handled by executeCurrent; transition out after cooldown
      case EnemyAiState.cooldown:
        if (_stateTimer >= 0.8) _transition(EnemyAiState.chase);
      case EnemyAiState.retreat:
        if (_stateTimer >= 1.2) _transition(EnemyAiState.chase);
      case EnemyAiState.dead:
        break;
      case EnemyAiState.idle:
        if (_stateTimer >= 2.0) _transition(EnemyAiState.patrol);
    }
  }

  void _executeCurrent() {
    switch (_state) {
      case EnemyAiState.patrol:   onPatrol?.call();
      case EnemyAiState.chase:    onChase?.call();
      case EnemyAiState.attack:
        onAttack?.call();
        _attackCooldown = 1.5;
        _transition(EnemyAiState.cooldown);
      case EnemyAiState.cooldown: onCooldown?.call();
      case EnemyAiState.retreat:  onRetreat?.call();
      case EnemyAiState.dead:     onDeath?.call();
      case EnemyAiState.idle:     break;
    }
  }

  void _transition(EnemyAiState next) {
    _state      = next;
    _stateTimer = 0.0;
  }

  void triggerDeath() => _transition(EnemyAiState.dead);
}

enum EnemyAiState { idle, patrol, chase, attack, cooldown, retreat, dead }
