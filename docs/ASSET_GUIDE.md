# Veilborn — Asset Guide
**Version:** 1.0 | **Phase:** 9 — Asset Integration
**Audience:** Pixel artists, sound designers, level designers

This document specifies every asset file Veilborn expects, with exact
filenames, dimensions, frame counts, and drop-in paths. All paths are
relative to `assets/` and already declared in `pubspec.yaml` — **just
drop files into the listed folders with the exact filenames below** and
they'll load automatically via `AssetManager`.

No code changes required. The game currently runs on geometric
placeholders (`RectangleComponent`) and will automatically switch to
real sprites once files matching these paths exist.

---

## 🎨 Art Style Reference

- **Palette:** Dark fantasy, desaturated. Void black (`#0D0A14`), ashen
  grey (`#3A3550`), Veil purple (`#6B3FA0`), ember amber (`#F5A623`)
  is the ONLY warm colour — reserved for candlelight/safe rooms.
- **Resolution:** All sprite sheets at native pixel-art resolution.
  Game viewport is 480×270 (16:9). Recommend 16px or 32px tile grid.
- **Style:** Hand-drawn pixel art, NOT vector/flat. Slight grain/dither
  acceptable. No anti-aliasing on outlines.
- See `Art Design Bible` (Confluence, KAN-27) for full character/world/
  weapon visual specs and reference renders.

---

## 🧍 Player Sprites — `assets/images/player/`

Each file is a horizontal sprite sheet. Frame size and count below.
All 4 skins (Ashen Knight, Void Stalker, Crimson Seraph, Golden Warden)
share these sheets — skin colour is applied via a **paint tint overlay**
in code, so deliver sprites in **neutral grey** for correct tinting.

| Filename | Frame size | Frames | Loop | Notes |
|---|---|---|---|---|
| `idle.png` | 32×48 | 4 | ✅ | Subtle breathing/sway |
| `run.png` | 32×48 | 8 | ✅ | Full run cycle |
| `jump.png` | 32×48 | 3 | ❌ | Rise pose, held at apex |
| `fall.png` | 32×48 | 2 | ✅ | Falling pose |
| `dash.png` | 32×48 | 4 | ❌ | Motion-blur streak frames |
| `attack.png` | 48×48 | 6 | ❌ | Covers light combo (3 swings) + heavy |
| `wall_slide.png` | 32×48 | 2 | ✅ | Pressed against wall |
| `death.png` | 32×48 | 6 | ❌ | Collapse animation |

**Stride note:** sheets are read left-to-right, single row. Frame width
× frame count = total sheet width. Height = frame height.

---

## 👹 Enemy Sprites — `assets/images/enemies/`

Each enemy needs 3–4 states. Frame sizes match each enemy's hitbox
(see Art Design Bible for exact dimensions).

### Wanderer (28×40)
| Filename | Frames | Loop |
|---|---|---|
| `wanderer_idle.png` | 4 | ✅ |
| `wanderer_move.png` | 6 | ✅ |
| `wanderer_attack.png` | 4 | ❌ |
| `wanderer_death.png` | 5 | ❌ |

### Wraith (26×36)
| Filename | Frames | Loop |
|---|---|---|
| `wraith_idle.png` | 4 | ✅ — include float bob |
| `wraith_move.png` | 4 | ✅ |
| `wraith_attack.png` | 4 | ❌ — lunge |
| `wraith_death.png` | 5 | ❌ — dissolve |

### Crawler (32×20)
| Filename | Frames | Loop |
|---|---|---|
| `crawler_idle.png` | 3 | ✅ — ceiling cling |
| `crawler_move.png` | 6 | ✅ |
| `crawler_drop.png` | 3 | ❌ — drop-attack |
| `crawler_death.png` | 4 | ❌ |

### Shade (28×42)
| Filename | Frames | Loop |
|---|---|---|
| `shade_idle.png` | 4 | ✅ |
| `shade_teleport.png` | 5 | ❌ — fade out/in |
| `shade_attack.png` | 4 | ❌ — shadow bolt cast |
| `shade_death.png` | 5 | ❌ |

### Husk (52×60)
| Filename | Frames | Loop |
|---|---|---|
| `husk_idle.png` | 3 | ✅ |
| `husk_move.png` | 6 | ✅ — heavy shuffle |
| `husk_slam.png` | 6 | ❌ — wind-up + slam |
| `husk_death.png` | 6 | ❌ |

---

## 👑 Boss Sprites — `assets/images/enemies/bosses/`

### Ashen Warden (64×80) — Chapter 1
| Filename | Frames | Loop | Notes |
|---|---|---|---|
| `warden_idle.png` | 4 | ✅ | |
| `warden_walk.png` | 6 | ✅ | |
| `warden_attack.png` | 8 | ❌ | melee combo, 3 hits |
| `warden_slam.png` | 6 | ❌ | ground slam |
| `warden_phase2.png` | 4 | ✅ | Veil-corrupted idle, purple cracks glow |
| `warden_death.png` | 8 | ❌ | |

### Veil Seraph (72×88) — Chapter 2
| Filename | Frames | Loop | Notes |
|---|---|---|---|
| `seraph_idle.png` | 4 | ✅ | floating bob |
| `seraph_fly.png` | 6 | ✅ | |
| `seraph_attack.png` | 6 | ❌ | feather spread cast |
| `seraph_phase2.png` | 4 | ✅ | shedding dark feathers |
| `seraph_phase3.png` | 4 | ✅ | mask shattered, void energy |
| `seraph_death.png` | 8 | ❌ | |

---

## 🖼️ UI / HUD Assets — `assets/images/ui/`

| Filename | Size | Notes |
|---|---|---|
| `candle_flame.png` | 48×64 | Used on splash screen — can replace `_CandlePainter` |
| `bar_health.png` | 200×16 | 9-slice or stretch fill texture, red |
| `bar_stamina.png` | 200×16 | Teal fill texture |
| `bar_sanity.png` | 200×16 | White→purple gradient fill |
| `soul_essence.png` | 16×16 | Pickup icon, white/purple orb |
| `skill_icons.png` | 32×32 ×12 | Sprite sheet, 12 icons in a row — one per skill (see skill order below) |

**Skill icon order** (left to right in `skill_icons.png`):
`bloodEdge, voidStrike, soulDrain, phantomBlade, ironWill, secondWind, grounded, resilience, shadowStep, wallrunner, featherfall, blink`

---

## 🏞️ Background Layers — `assets/images/backgrounds/`

Parallax layers, each 480px tall (full viewport height), tileable
horizontally. Recommend 960px+ width for seamless scroll.

| Filename | Chapter | Notes |
|---|---|---|
| `ch1_sky.png` | 1 | Ashen sky, ember glow points |
| `ch1_mid.png` | 1 | Distant ruined structures |
| `ch1_fore.png` | 1 | Foreground rubble silhouettes |
| `ch2_sky.png` | 2 | Void purple, rift tears |
| `ch2_mid.png` | 2 | Cathedral silhouettes |
| `ch2_fore.png` | 2 | Foreground pillars/debris |

---

## 🗺️ Tiled Maps — `assets/tiles/chapter1/` & `chapter2/`

Built in [Tiled Map Editor](https://www.mapeditor.org/), exported as
`.tmx` (XML). Tile size: **16×16px**. Each map needs two object layers:

- **`Collision`** — rectangles marking solid platform geometry
- **`Enemies`** — point objects named exactly `Wanderer`, `Wraith`,
  `Crawler`, `Shade`, `Husk` (case-sensitive) at spawn positions

### Chapter 1 — Ashen Ruins (tileset: `ashen_ruins.tsx`)
| Filename | Role |
|---|---|
| `ch1_opener.tmx` | Always first chunk — gentle intro |
| `ch1_combat_a.tmx` | Mid-pool — combat-focused |
| `ch1_platform_b.tmx` | Mid-pool — platforming-focused |
| `ch1_hybrid_c.tmx` | Mid-pool — mixed |
| `ch1_dark_zone.tmx` | Mid-pool — sets `inDarkZone=true` (filename trigger) |
| `ch1_safe_room.tmx` | Mid-pool — sets `inSafeRoom=true` (filename trigger) |
| `ch1_gauntlet.tmx` | Always last chunk — toughest |
| `ch1_boss_room.tmx` | Boss arena — spawns AshenWarden |

### Chapter 2 — Veil Sanctum (tileset: `veil_sanctum.tsx`)
Same structure, replace `ch1_*` → `ch2_*`, plus `ch2_veil_rift.tmx`
(dark-zone equivalent — filename must contain `veil_rift` or `dark_zone`).

---

## 🔊 Sound Effects — `assets/audio/sfx/`

Format: **OGG Vorbis**, mono or stereo, 44.1kHz. Keep under 2s each
except where noted. Normalize to −6dB peak.

| Filename | Trigger | Length |
|---|---|---|
| `sfx_attack_light.ogg` | Light melee swing | <0.3s |
| `sfx_attack_heavy.ogg` | Heavy attack | <0.5s |
| `sfx_attack_ranged.ogg` | Ranged projectile cast | <0.3s |
| `sfx_player_hit.ogg` | Player takes damage | <0.4s |
| `sfx_dash.ogg` | Dash activated | <0.3s |
| `sfx_player_death.ogg` | Player dies | 1–2s |
| `sfx_enemy_hit.ogg` | Enemy takes damage | <0.3s |
| `sfx_enemy_death.ogg` | Enemy dies | <0.6s |
| `sfx_boss_phase.ogg` | Boss phase transition | 1–2s, dramatic |
| `sfx_sanity_drain.ogg` | Sanity threshold crossed (low/critical) | 0.5–1s, unsettling |
| `sfx_soul_essence.ogg` | Soul Essence pickup | <0.3s, bright |
| `sfx_level_complete.ogg` | Level/chapter complete | 1–2s |
| `sfx_ui_select.ogg` | Menu button tap | <0.2s |
| `sfx_ui_back.ogg` | Back navigation | <0.2s |
| `sfx_skill_select.ogg` | Skill card chosen | <0.4s |
| `sfx_purchase.ogg` | IAP purchase success | <0.5s, satisfying |

---

## 🎵 Music — `assets/audio/music/`

Format: **OGG Vorbis**, stereo, 44.1kHz, loop-ready (seamless start/end).
Target length: 1.5–3 minutes per loop.

| Filename | Context | Mood |
|---|---|---|
| `bgm_main_menu.ogg` | Main menu | Atmospheric, slow, inviting dread |
| `bgm_ch1_explore.ogg` | Chapter 1 exploration | Ashen, sparse, percussion-led |
| `bgm_ch1_boss.ogg` | Ashen Warden fight | Intense, brass/percussion |
| `bgm_ch2_explore.ogg` | Chapter 2 exploration | Choral, eerie, reverb-heavy |
| `bgm_ch2_boss.ogg` | Veil Seraph fight | Climactic, dissonant strings |
| `bgm_game_over.ogg` | Death screen | Mournful, short (30–60s, non-looping OK) |

**Sanity-reactive note:** `AudioManager` applies real-time pitch/volume
shifts to whatever track is playing at low Sanity — no separate
"distorted" mix files needed.

---

## 🔤 Fonts — `assets/fonts/`

| Filename | Family name (pubspec) | Usage |
|---|---|---|
| `VeilbornDisplay.ttf` | `VeilbornDisplay` | Titles, large HUD numbers — recommend a refined serif or display face |
| `VeilbornBody.ttf` | `VeilbornBody` | Body text, descriptions — recommend a clean sans-serif |

Currently the UI uses system default fonts. Once these files are added,
apply via `TextStyle(fontFamily: 'VeilbornDisplay')` in relevant widgets
(not yet wired — flag for Phase 10 if fonts are delivered).

---

## ✅ Integration Checklist

When dropping in a new batch of assets:

1. Place files in the exact paths/filenames above (case-sensitive).
2. Run `flutter pub get` (picks up any new files in declared directories).
3. Run the game — `AssetManager.preloadAll()` logs `[Assets] skip …` for
   any still-missing files; once the log is silent, integration is complete.
4. For sprite sheets: verify frame size/count matches the table — Flame's
   `SpriteAnimation.fromFrameData` will throw if dimensions don't divide evenly.
5. For Tiled maps: open in Tiled, verify `Collision` and `Enemies` object
   layers exist with correct names.
6. Commit to a `feature/phase-N-assets-batch-X` branch, open PR.

---

*Veilborn Asset Guide v1.0 — AI Game Studio — Phase 9*
