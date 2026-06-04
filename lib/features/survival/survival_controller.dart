import 'package:flame/components.dart';
import '../../core/utils/constants.dart';

/// Manages the three survival resources: Health, Stamina, Sanity.
///
/// This is Veilborn's signature system. Attach to PlayerComponent.
/// Notifies listeners on threshold crossings for visual/audio effects.
class SurvivalController extends Component with HasGameRef {
  // ── Health ────────────────────────────────────────────────
  double health    = GameConstants.playerBaseHealth;
  double maxHealth = GameConstants.playerBaseHealth;

  // ── Stamina ───────────────────────────────────────────────
  double stamina    = GameConstants.playerBaseStamina;
  double maxStamina = GameConstants.playerBaseStamina;
  double _staminaRegenTimer = 0.0;

  // ── Sanity ────────────────────────────────────────────────
  double sanity    = GameConstants.playerBaseSanity;
  double maxSanity = GameConstants.playerBaseSanity; // NOT upgradeable
  int    _zeroSanityCount = 0; // Run fails on 2nd zero

  // ── Context flags (set by level systems) ──────────────────
  bool inDarkZone  = false;
  bool nearVeilTear = false;
  bool nearBoss    = false;
  bool inSafeRoom  = false;

  // ── Callbacks ─────────────────────────────────────────────
  /// Called when sanity crosses a threshold (75/50/25/0)
  void Function(SanityThreshold threshold)? onSanityThresholdCrossed;

  /// Called when health reaches zero
  void Function()? onDeath;

  // ── Sanity threshold tracking ─────────────────────────────
  SanityThreshold _currentThreshold = SanityThreshold.normal;

  @override
  void update(double dt) {
    _updateStamina(dt);
    _updateSanity(dt);
    _checkSanityThreshold();
  }

  // ── Stamina logic ─────────────────────────────────────────
  void _updateStamina(double dt) {
    if (stamina < maxStamina) {
      _staminaRegenTimer += dt;
      if (_staminaRegenTimer >= GameConstants.staminaRegenDelay) {
        stamina = (stamina + GameConstants.staminaRegenRate * dt)
            .clamp(0.0, maxStamina);
      }
    }
  }

  /// Returns true if stamina was successfully consumed.
  bool consumeStamina(double amount) {
    if (stamina < amount) return false;
    stamina -= amount;
    _staminaRegenTimer = 0.0; // Reset regen delay
    return true;
  }

  bool get canDash   => stamina >= GameConstants.staminaDashCost;
  bool get canSprint => stamina >= 1.0;

  // ── Sanity logic ──────────────────────────────────────────
  void _updateSanity(double dt) {
    double drain = 0.0;

    if (inDarkZone)   drain += GameConstants.sanityDrainDarkZone;
    if (nearVeilTear) drain += GameConstants.sanityDrainVeilTear;
    if (nearBoss)     drain += GameConstants.sanityDrainBossProx;

    if (drain > 0) {
      sanity = (sanity - drain * dt).clamp(0.0, maxSanity);
      if (sanity == 0) _onSanityZero();
    }

    if (inSafeRoom && sanity < maxSanity) {
      sanity = (sanity + GameConstants.sanityRegenSafeRoom * dt)
          .clamp(0.0, maxSanity);
    }
  }

  void drainSanityOnHit() {
    sanity = (sanity - GameConstants.sanityDrainOnHit).clamp(0.0, maxSanity);
    if (sanity == 0) _onSanityZero();
    _checkSanityThreshold();
  }

  void restoreSanity(double amount) {
    sanity = (sanity + amount).clamp(0.0, maxSanity);
    _checkSanityThreshold();
  }

  void _onSanityZero() {
    _zeroSanityCount++;
    if (_zeroSanityCount >= 2) {
      // Run fails — trigger game over
      onDeath?.call();
    }
  }

  void _checkSanityThreshold() {
    final newThreshold = _thresholdFor(sanity);
    if (newThreshold != _currentThreshold) {
      _currentThreshold = newThreshold;
      onSanityThresholdCrossed?.call(newThreshold);
    }
  }

  SanityThreshold _thresholdFor(double s) {
    if (s <= GameConstants.sanityThresholdCrit)  return SanityThreshold.zero;
    if (s <= GameConstants.sanityThresholdLow)   return SanityThreshold.critical;
    if (s <= GameConstants.sanityThresholdMid)   return SanityThreshold.low;
    if (s <= GameConstants.sanityThresholdHigh)  return SanityThreshold.mid;
    return SanityThreshold.normal;
  }

  // ── Health logic ──────────────────────────────────────────
  void takeDamage(double amount) {
    health = (health - amount).clamp(0.0, maxHealth);
    if (health == 0) onDeath?.call();
  }

  void heal(double amount) {
    health = (health + amount).clamp(0.0, maxHealth);
  }

  // ── Upgrade hooks (called by skill system) ────────────────
  void upgradeMaxHealth(double amount)  => maxHealth += amount;
  void upgradeMaxStamina(double amount) => maxStamina += amount;
  void increaseStaminaRegen(double multiplier) {} // TODO: apply multiplier

  // ── Serialization (for save system) ──────────────────────
  Map<String, dynamic> toJson() => {
    'health':  health,
    'stamina': stamina,
    'sanity':  sanity,
  };
}

enum SanityThreshold {
  normal,   // 75–100: no effects
  mid,      // 50–74:  vignette + reverb
  low,      // 25–49:  distortion + fake enemies
  critical, // 1–24:   platform flicker + HUD scramble
  zero,     // 0:      hallucination mode
}
