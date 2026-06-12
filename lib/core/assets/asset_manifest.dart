/// Central registry of every asset path used in Veilborn.
///
/// Usage:
/// ```dart
/// await gameRef.images.load(PlayerAssets.idleSheet);
/// await FlameAudio.audioCache.load(SfxAssets.playerAttackLight);
/// ```
///
/// All paths are relative to the project `assets/` root as declared
/// in `pubspec.yaml`. Add new assets here before referencing them in code.

// ── Player sprite sheets ──────────────────────────────────────
class PlayerAssets {
  PlayerAssets._();

  // Shared across all skins — loaded at game start
  static const String idleSheet      = 'images/player/idle.png';
  static const String runSheet       = 'images/player/run.png';
  static const String jumpSheet      = 'images/player/jump.png';
  static const String fallSheet      = 'images/player/fall.png';
  static const String dashSheet      = 'images/player/dash.png';
  static const String attackSheet    = 'images/player/attack.png';
  static const String wallSlideSheet = 'images/player/wall_slide.png';
  static const String deathSheet     = 'images/player/death.png';

  // Skin overlay tints (applied via paint — no separate sheets needed)
  // Ashen Knight: default palette
  // Void Stalker: purple tint overlay
  // Crimson Seraph: red tint overlay
  // Golden Warden: amber tint overlay

  static const List<String> all = [
    idleSheet, runSheet, jumpSheet, fallSheet,
    dashSheet, attackSheet, wallSlideSheet, deathSheet,
  ];
}

// ── Enemy sprite sheets ───────────────────────────────────────
class EnemyAssets {
  EnemyAssets._();

  // Each enemy has: idle, move, attack, death
  static const String wandererIdle   = 'images/enemies/wanderer_idle.png';
  static const String wandererMove   = 'images/enemies/wanderer_move.png';
  static const String wandererAttack = 'images/enemies/wanderer_attack.png';
  static const String wandererDeath  = 'images/enemies/wanderer_death.png';

  static const String wraithIdle     = 'images/enemies/wraith_idle.png';
  static const String wraithMove     = 'images/enemies/wraith_move.png';
  static const String wraithAttack   = 'images/enemies/wraith_attack.png';
  static const String wraithDeath    = 'images/enemies/wraith_death.png';

  static const String crawlerIdle    = 'images/enemies/crawler_idle.png';
  static const String crawlerMove    = 'images/enemies/crawler_move.png';
  static const String crawlerDrop    = 'images/enemies/crawler_drop.png';
  static const String crawlerDeath   = 'images/enemies/crawler_death.png';

  static const String shadeIdle      = 'images/enemies/shade_idle.png';
  static const String shadeTeleport  = 'images/enemies/shade_teleport.png';
  static const String shadeAttack    = 'images/enemies/shade_attack.png';
  static const String shadeDeath     = 'images/enemies/shade_death.png';

  static const String huskIdle       = 'images/enemies/husk_idle.png';
  static const String huskMove       = 'images/enemies/husk_move.png';
  static const String huskSlam       = 'images/enemies/husk_slam.png';
  static const String huskDeath      = 'images/enemies/husk_death.png';

  static const List<String> all = [
    wandererIdle, wandererMove, wandererAttack, wandererDeath,
    wraithIdle,   wraithMove,   wraithAttack,   wraithDeath,
    crawlerIdle,  crawlerMove,  crawlerDrop,    crawlerDeath,
    shadeIdle,    shadeTeleport,shadeAttack,    shadeDeath,
    huskIdle,     huskMove,     huskSlam,       huskDeath,
  ];
}

// ── Boss sprite sheets ────────────────────────────────────────
class BossAssets {
  BossAssets._();

  // Ashen Warden — Chapter 1
  static const String wardenIdle      = 'images/enemies/bosses/warden_idle.png';
  static const String wardenWalk      = 'images/enemies/bosses/warden_walk.png';
  static const String wardenAttack    = 'images/enemies/bosses/warden_attack.png';
  static const String wardenSlam      = 'images/enemies/bosses/warden_slam.png';
  static const String wardenPhase2    = 'images/enemies/bosses/warden_phase2.png';
  static const String wardenDeath     = 'images/enemies/bosses/warden_death.png';

  // Veil Seraph — Chapter 2
  static const String seraphIdle      = 'images/enemies/bosses/seraph_idle.png';
  static const String seraphFly       = 'images/enemies/bosses/seraph_fly.png';
  static const String seraphAttack    = 'images/enemies/bosses/seraph_attack.png';
  static const String seraphPhase2    = 'images/enemies/bosses/seraph_phase2.png';
  static const String seraphPhase3    = 'images/enemies/bosses/seraph_phase3.png';
  static const String seraphDeath     = 'images/enemies/bosses/seraph_death.png';

  static const List<String> all = [
    wardenIdle, wardenWalk, wardenAttack, wardenSlam, wardenPhase2, wardenDeath,
    seraphIdle, seraphFly,  seraphAttack, seraphPhase2, seraphPhase3, seraphDeath,
  ];
}

// ── UI / HUD assets ───────────────────────────────────────────
class UiAssets {
  UiAssets._();

  static const String candleFlame     = 'images/ui/candle_flame.png';
  static const String healthBarFill   = 'images/ui/bar_health.png';
  static const String staminaBarFill  = 'images/ui/bar_stamina.png';
  static const String sanityBarFill   = 'images/ui/bar_sanity.png';
  static const String soulEssenceIcon = 'images/ui/soul_essence.png';
  static const String skillIconSheet  = 'images/ui/skill_icons.png';

  static const List<String> all = [
    candleFlame, healthBarFill, staminaBarFill,
    sanityBarFill, soulEssenceIcon, skillIconSheet,
  ];
}

// ── Background / environment ──────────────────────────────────
class BackgroundAssets {
  BackgroundAssets._();

  static const String ch1Sky          = 'images/backgrounds/ch1_sky.png';
  static const String ch1MidLayer     = 'images/backgrounds/ch1_mid.png';
  static const String ch1ForeLayer    = 'images/backgrounds/ch1_fore.png';
  static const String ch2Sky          = 'images/backgrounds/ch2_sky.png';
  static const String ch2MidLayer     = 'images/backgrounds/ch2_mid.png';
  static const String ch2ForeLayer    = 'images/backgrounds/ch2_fore.png';

  static const List<String> all = [
    ch1Sky, ch1MidLayer, ch1ForeLayer,
    ch2Sky, ch2MidLayer, ch2ForeLayer,
  ];
}

// ── Tiled map files ───────────────────────────────────────────
class TileAssets {
  TileAssets._();

  // Chapter 1 — Ashen Ruins
  static const String ch1Tileset      = 'tiles/chapter1/ashen_ruins.tsx';
  static const String ch1Opener       = 'tiles/chapter1/ch1_opener.tmx';
  static const String ch1CombatA      = 'tiles/chapter1/ch1_combat_a.tmx';
  static const String ch1PlatformB    = 'tiles/chapter1/ch1_platform_b.tmx';
  static const String ch1HybridC      = 'tiles/chapter1/ch1_hybrid_c.tmx';
  static const String ch1DarkZone     = 'tiles/chapter1/ch1_dark_zone.tmx';
  static const String ch1SafeRoom     = 'tiles/chapter1/ch1_safe_room.tmx';
  static const String ch1Gauntlet     = 'tiles/chapter1/ch1_gauntlet.tmx';
  static const String ch1BossRoom     = 'tiles/chapter1/ch1_boss_room.tmx';

  // Chapter 2 — Veil Sanctum
  static const String ch2Tileset      = 'tiles/chapter2/veil_sanctum.tsx';
  static const String ch2Opener       = 'tiles/chapter2/ch2_opener.tmx';
  static const String ch2CombatA      = 'tiles/chapter2/ch2_combat_a.tmx';
  static const String ch2PlatformB    = 'tiles/chapter2/ch2_platform_b.tmx';
  static const String ch2VeilRift     = 'tiles/chapter2/ch2_veil_rift.tmx';
  static const String ch2DarkZone     = 'tiles/chapter2/ch2_dark_zone.tmx';
  static const String ch2SafeRoom     = 'tiles/chapter2/ch2_safe_room.tmx';
  static const String ch2Gauntlet     = 'tiles/chapter2/ch2_gauntlet.tmx';
  static const String ch2BossRoom     = 'tiles/chapter2/ch2_boss_room.tmx';
}

// ── SFX files ─────────────────────────────────────────────────
class SfxAssets {
  SfxAssets._();

  static const String playerAttackLight  = 'audio/sfx/sfx_attack_light.ogg';
  static const String playerAttackHeavy  = 'audio/sfx/sfx_attack_heavy.ogg';
  static const String playerAttackRanged = 'audio/sfx/sfx_attack_ranged.ogg';
  static const String playerHit          = 'audio/sfx/sfx_player_hit.ogg';
  static const String playerDash         = 'audio/sfx/sfx_dash.ogg';
  static const String playerDeath        = 'audio/sfx/sfx_player_death.ogg';
  static const String enemyHit           = 'audio/sfx/sfx_enemy_hit.ogg';
  static const String enemyDeath         = 'audio/sfx/sfx_enemy_death.ogg';
  static const String bossPhaseShift     = 'audio/sfx/sfx_boss_phase.ogg';
  static const String sanityDrain        = 'audio/sfx/sfx_sanity_drain.ogg';
  static const String soulEssencePick    = 'audio/sfx/sfx_soul_essence.ogg';
  static const String levelComplete      = 'audio/sfx/sfx_level_complete.ogg';
  static const String uiSelect           = 'audio/sfx/sfx_ui_select.ogg';
  static const String uiBack             = 'audio/sfx/sfx_ui_back.ogg';
  static const String skillSelect        = 'audio/sfx/sfx_skill_select.ogg';
  static const String purchaseSuccess    = 'audio/sfx/sfx_purchase.ogg';

  static const List<String> all = [
    playerAttackLight, playerAttackHeavy, playerAttackRanged,
    playerHit, playerDash, playerDeath,
    enemyHit, enemyDeath, bossPhaseShift,
    sanityDrain, soulEssencePick, levelComplete,
    uiSelect, uiBack, skillSelect, purchaseSuccess,
  ];
}

// ── BGM files ─────────────────────────────────────────────────
class BgmAssets {
  BgmAssets._();

  static const String mainMenu    = 'audio/music/bgm_main_menu.ogg';
  static const String ch1Explore  = 'audio/music/bgm_ch1_explore.ogg';
  static const String ch1Boss     = 'audio/music/bgm_ch1_boss.ogg';
  static const String ch2Explore  = 'audio/music/bgm_ch2_explore.ogg';
  static const String ch2Boss     = 'audio/music/bgm_ch2_boss.ogg';
  static const String gameOver    = 'audio/music/bgm_game_over.ogg';

  static const List<String> all = [
    mainMenu, ch1Explore, ch1Boss, ch2Explore, ch2Boss, gameOver,
  ];
}

// ── Font files ────────────────────────────────────────────────
class FontAssets {
  FontAssets._();

  /// Primary display font — used for titles, HUD numbers
  static const String veilbornDisplay = 'fonts/VeilbornDisplay.ttf';

  /// Body font — used for descriptions, UI text
  static const String veilbornBody    = 'fonts/VeilbornBody.ttf';
}
