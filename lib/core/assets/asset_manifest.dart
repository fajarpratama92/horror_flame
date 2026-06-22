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
  static const String idleSheet      = 'player/idle.png';
  static const String runSheet       = 'player/run.png';
  static const String jumpSheet      = 'player/jump.png';
  static const String fallSheet      = 'player/fall.png';
  static const String dashSheet      = 'player/dash.png';
  static const String attackSheet    = 'player/attack.png';
  static const String wallSlideSheet = 'player/wall_slide.png';
  static const String deathSheet     = 'player/death.png';

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
  static const String wandererIdle   = 'enemies/wanderer_idle.png';
  static const String wandererMove   = 'enemies/wanderer_move.png';
  static const String wandererAttack = 'enemies/wanderer_attack.png';
  static const String wandererDeath  = 'enemies/wanderer_death.png';

  static const String wraithIdle     = 'enemies/wraith_idle.png';
  static const String wraithMove     = 'enemies/wraith_move.png';
  static const String wraithAttack   = 'enemies/wraith_attack.png';
  static const String wraithDeath    = 'enemies/wraith_death.png';

  static const String crawlerIdle    = 'enemies/crawler_idle.png';
  static const String crawlerMove    = 'enemies/crawler_move.png';
  static const String crawlerDrop    = 'enemies/crawler_drop.png';
  static const String crawlerDeath   = 'enemies/crawler_death.png';

  static const String shadeIdle      = 'enemies/shade_idle.png';
  static const String shadeTeleport  = 'enemies/shade_teleport.png';
  static const String shadeAttack    = 'enemies/shade_attack.png';
  static const String shadeDeath     = 'enemies/shade_death.png';

  static const String huskIdle       = 'enemies/husk_idle.png';
  static const String huskMove       = 'enemies/husk_move.png';
  static const String huskSlam       = 'enemies/husk_slam.png';
  static const String huskDeath      = 'enemies/husk_death.png';

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
  static const String wardenIdle      = 'enemies/bosses/warden_idle.png';
  static const String wardenWalk      = 'enemies/bosses/warden_walk.png';
  static const String wardenAttack    = 'enemies/bosses/warden_attack.png';
  static const String wardenSlam      = 'enemies/bosses/warden_slam.png';
  static const String wardenPhase2    = 'enemies/bosses/warden_phase2.png';
  static const String wardenDeath     = 'enemies/bosses/warden_death.png';

  // Veil Seraph — Chapter 2
  static const String seraphIdle      = 'enemies/bosses/seraph_idle.png';
  static const String seraphFly       = 'enemies/bosses/seraph_fly.png';
  static const String seraphAttack    = 'enemies/bosses/seraph_attack.png';
  static const String seraphPhase2    = 'enemies/bosses/seraph_phase2.png';
  static const String seraphPhase3    = 'enemies/bosses/seraph_phase3.png';
  static const String seraphDeath     = 'enemies/bosses/seraph_death.png';

  static const List<String> all = [
    wardenIdle, wardenWalk, wardenAttack, wardenSlam, wardenPhase2, wardenDeath,
    seraphIdle, seraphFly,  seraphAttack, seraphPhase2, seraphPhase3, seraphDeath,
  ];
}

// ── UI / HUD assets ───────────────────────────────────────────
class UiAssets {
  UiAssets._();

  static const String candleFlame     = 'ui/candle_flame.png';
  static const String healthBarFill   = 'ui/bar_health.png';
  static const String staminaBarFill  = 'ui/bar_stamina.png';
  static const String sanityBarFill   = 'ui/bar_sanity.png';
  static const String soulEssenceIcon = 'ui/soul_essence.png';
  static const String skillIconSheet  = 'ui/skill_icons.png';

  static const List<String> all = [
    candleFlame, healthBarFill, staminaBarFill,
    sanityBarFill, soulEssenceIcon, skillIconSheet,
  ];
}

// ── Background / environment ──────────────────────────────────
class BackgroundAssets {
  BackgroundAssets._();

  static const String ch1Sky          = 'backgrounds/ch1_sky.png';
  static const String ch1MidLayer     = 'backgrounds/ch1_mid.png';
  static const String ch1ForeLayer    = 'backgrounds/ch1_fore.png';
  static const String ch2Sky          = 'backgrounds/ch2_sky.png';
  static const String ch2MidLayer     = 'backgrounds/ch2_mid.png';
  static const String ch2ForeLayer    = 'backgrounds/ch2_fore.png';

  static const List<String> all = [
    ch1Sky, ch1MidLayer, ch1ForeLayer,
    ch2Sky, ch2MidLayer, ch2ForeLayer,
  ];
}

// ── Tiled map files ───────────────────────────────────────────
class TileAssets {
  TileAssets._();

  // Chapter 1 — Ashen Ruins
  static const String ch1Tileset      = 'chapter1/ashen_ruins.tsx';
  static const String ch1Opener       = 'chapter1/ch1_opener.tmx';
  static const String ch1CombatA      = 'chapter1/ch1_combat_a.tmx';
  static const String ch1PlatformB    = 'chapter1/ch1_platform_b.tmx';
  static const String ch1HybridC      = 'chapter1/ch1_hybrid_c.tmx';
  static const String ch1DarkZone     = 'chapter1/ch1_dark_zone.tmx';
  static const String ch1SafeRoom     = 'chapter1/ch1_safe_room.tmx';
  static const String ch1Gauntlet     = 'chapter1/ch1_gauntlet.tmx';
  static const String ch1BossRoom     = 'chapter1/ch1_boss_room.tmx';

  // Chapter 2 — Veil Sanctum
  static const String ch2Tileset      = 'chapter2/veil_sanctum.tsx';
  static const String ch2Opener       = 'chapter2/ch2_opener.tmx';
  static const String ch2CombatA      = 'chapter2/ch2_combat_a.tmx';
  static const String ch2PlatformB    = 'chapter2/ch2_platform_b.tmx';
  static const String ch2VeilRift     = 'chapter2/ch2_veil_rift.tmx';
  static const String ch2DarkZone     = 'chapter2/ch2_dark_zone.tmx';
  static const String ch2SafeRoom     = 'chapter2/ch2_safe_room.tmx';
  static const String ch2Gauntlet     = 'chapter2/ch2_gauntlet.tmx';
  static const String ch2BossRoom     = 'chapter2/ch2_boss_room.tmx';
}

// ── SFX files ─────────────────────────────────────────────────
class SfxAssets {
  SfxAssets._();

  static const String playerAttackLight  = 'sfx/sfx_attack_light.ogg';
  static const String playerAttackHeavy  = 'sfx/sfx_attack_heavy.ogg';
  static const String playerAttackRanged = 'sfx/sfx_attack_ranged.ogg';
  static const String playerHit          = 'sfx/sfx_player_hit.ogg';
  static const String playerDash         = 'sfx/sfx_dash.ogg';
  static const String playerDeath        = 'sfx/sfx_player_death.ogg';
  static const String enemyHit           = 'sfx/sfx_enemy_hit.ogg';
  static const String enemyDeath         = 'sfx/sfx_enemy_death.ogg';
  static const String bossPhaseShift     = 'sfx/sfx_boss_phase.ogg';
  static const String sanityDrain        = 'sfx/sfx_sanity_drain.ogg';
  static const String soulEssencePick    = 'sfx/sfx_soul_essence.ogg';
  static const String levelComplete      = 'sfx/sfx_level_complete.ogg';
  static const String uiSelect           = 'sfx/sfx_ui_select.ogg';
  static const String uiBack             = 'sfx/sfx_ui_back.ogg';
  static const String skillSelect        = 'sfx/sfx_skill_select.ogg';
  static const String purchaseSuccess    = 'sfx/sfx_purchase.ogg';

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

  static const String mainMenu    = 'music/bgm_main_menu.ogg';
  static const String ch1Explore  = 'music/bgm_ch1_explore.ogg';
  static const String ch1Boss     = 'music/bgm_ch1_boss.ogg';
  static const String ch2Explore  = 'music/bgm_ch2_explore.ogg';
  static const String ch2Boss     = 'music/bgm_ch2_boss.ogg';
  static const String gameOver    = 'music/bgm_game_over.ogg';

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
