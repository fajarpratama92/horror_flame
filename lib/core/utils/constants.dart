/// Central location for all game-wide constants.
/// Never hardcode magic numbers — define them here.
class GameConstants {
  GameConstants._();

  // ── Identity ──────────────────────────────────────────────
  static const String gameTitle = 'Veilborn';
  static const String version   = '0.1.0';

  // ── Viewport ──────────────────────────────────────────────
  /// Design resolution — all positions are relative to this.
  static const double viewportWidth  = 480.0;
  static const double viewportHeight = 270.0;

  // ── Player ────────────────────────────────────────────────
  static const double playerBaseHealth   = 100.0;
  static const double playerBaseStamina  = 100.0;
  static const double playerBaseSanity   = 100.0;
  static const double playerMoveSpeed    = 180.0; // px/s
  static const double playerJumpForce    = -420.0;
  static const double playerDashForce    = 320.0;
  static const double playerDashDuration = 0.18;  // seconds
  static const int    playerDashIFrames  = 8;      // frames
  static const double playerIFrameDuration = 0.8; // seconds after hit
  static const double coyoteTimeDuration  = 0.1;  // seconds
  static const double jumpBufferDuration  = 0.08; // seconds

  // ── Stamina ───────────────────────────────────────────────
  static const double staminaDashCost    = 25.0;
  static const double staminaHeavyCost   = 15.0;
cstatic const double staminaRangedCost  = 20.0;
  static const double staminaSprintCost  = 10.0; // per second
  static const double staminaRegenRate   = 20.0; // per second
  static const double staminaRegenDelay  = 1.5;  // seconds before regen

  // ── Sanity ────────────────────────────────────────────────
  static const double sanityDrainDarkZone  = 5.0;  // per second
  static const double sanityDrainVeilTear  = 8.0;  // per second
  static const double sanityDrainBossProx  = 3.0;  // per second
  static const double sanityDrainOnHit     = 15.0; // per sanity-drain hit

  static const double sanityRegenSafeRoom  = 10.0; // per second
  static const double sanityRestoreCandle  = 30.0; // instant
  static const double sanityRestoreBossKill = 20.0;

  // Sanity effect thresholds
  static const double sanityThresholdHigh   = 75.0;
  static const double sanityThresholdMid    = 50.0;
  static const double sanityThresholdLow    = 25.0;
  static const double sanityThresholdCrit   = 0.0;

  // ── Combat ────────────────────────────────────────────────
  static const double lightAttackDamage    = 10.0;
  static const double heavyAttackDamage    = 25.0;
  static const double rangedAttackDamage   = 15.0;
  static const double comboFinisherDamage  = 40.0;
  static const double comboLauncherDamage  = 50.0; // 20 + 30
  static const double comboWindowDuration  = 1.2;  // seconds
  static const int    comboLightCount      = 3;    // hits before finisher

  // ── XP & Progression ──────────────────────────────────────
  static const int    maxLevelPerRun   = 10;
  static const int    skillChoiceCount = 3;  // choices shown on level up
  static const double xpLevelExponent  = 1.4;
  static const double xpBaseThreshold  = 100.0;

  // ── Level Design ──────────────────────────────────────────
  static const int    chunksPerChapter     = 8;   // pool size
  static const int    segmentsPerChapter   = 5;   // segments per run
  static const double gravity              = 900.0; // px/s²
  static const double maxFallSpeed         = 800.0;

  // ── Colours (also defined in theme — single source of truth) ──
  static const int colorVoidBlack    = 0xFF0D0A14;
  static const int colorAshenGrey    = 0xFF3A3550;
  static const int colorVeilPurple   = 0xFF6B3FA0;
  static const int colorCorrTeal     = 0xFF2A6B5C;
  static const int colorSanityWhite  = 0xFFE8E4FF;
  static const int colorCandlelight  = 0xFFF5A623;
  static const int colorCrimsonVoid  = 0xFF8B1A1A;
}
