# Veilborn — Release Notes
**Version:** 1.0.0 | **Release date:** TBD | **Build:** 1

---

## 🎮 What's in v1.0.0

This is the initial public release of Veilborn — a dark fantasy
action platformer survival game built with Flutter + Flame Engine.

### Chapters
- **Chapter 1: Ashen Ruins** — 5 procedurally arranged stages
  + Ashen Warden boss (2 phases)
- **Chapter 2: Veil Sanctum** — 5 procedurally arranged stages
  + Veil Seraph boss (3 phases)

### Core systems
- Responsive platformer physics (coyote time, jump buffer, wall-jump, dash)
- 3-hit combo melee + ranged combat with I-frames
- Survival trinity: Health, Stamina, Sanity
- **Sanity system** — 4 distortion thresholds with visual + audio effects
- 5 enemy types: Wanderer, Wraith, Crawler, Shade, Husk
- 12-skill RPG progression (3 per level, max level 10 per run)
- Procedural chunk assembly (different run order every session)
- XP system + skill selection screen
- Local save system (no account required)

### Characters & shop
- 4 character skins: Ashen Knight (free), Void Stalker (Ch1 unlock),
  Crimson Seraph ($1.99), Golden Warden ($2.99)
- Zero gameplay advantage from any purchase
- Restore purchases support (iOS)

### Audio
- Original dark fantasy soundtrack — 6 BGM tracks
- 16 SFX across all game events
- Sanity-reactive music (pitch + volume shift at thresholds)
- Full volume control: master, music, SFX

### Accessibility
- Reduce Motion mode — disables visual distortion effects
- Colour-blind mode — patterns used alongside colour cues
- Adjustable virtual button size

---

## 🔧 Technical

- **Engine:** Flutter 3.22 + Flame 1.x
- **Platforms:** iOS 13+ · Android API 21+
- **Target FPS:** 60fps (iPhone 12 / Snapdragon 765+)
- **App size:** <100MB initial download
- **Save system:** Local (SharedPreferences) — no server required

---

## ⚠️ Known limitations in v1.0.0

- Sprite art uses placeholder geometric shapes (real art in v1.1.0)
- Audio files require placement in `assets/audio/` (see setup guide)
- Tiled map files require placement in `assets/tiles/` (see setup guide)
- No cloud save / cross-device sync (planned for v1.1.0)
- No leaderboards (planned for v1.1.0)

---

# Changelog

## [1.0.0] — Initial Release

### Added — Core gameplay
- `PlayerComponent` — platformer physics with coyote time, jump buffer,
  wall-slide, wall-jump, dash with I-frames
- `InputController` — unified touch joystick + keyboard input layer
- 3-hit melee combo system with AoE finisher
- Heavy attack (knockback), ranged attack (projectile)
- `PhysicsBody` mixin — gravity, terminal velocity, platform collision

### Added — Enemies
- `Wanderer` — Tier 1 patrol/chase/melee (HP 30, DMG 10)
- `Wraith` — Tier 1 floating/lunging, sanity drain (HP 20, DMG 15)
- `Crawler` — Tier 2 ceiling/wall, drop attack (HP 25, DMG 12)
- `Shade` — Tier 2 elite, teleport, shadow bolt, sanity drain (HP 60, DMG 20)
- `Husk` — Tier 2 tank, AoE slam, charge attack (HP 120, DMG 30)
- `AiStateMachine` — Patrol→Chase→Attack→Cooldown→Retreat→Death

### Added — Bosses
- `AshenWarden` — 500 HP, 2 phases, Veil energy projectile spread
- `VeilSeraph` — 800 HP, 3 phases, reality distortion, wraith summons

### Added — Survival system
- `SurvivalController` — Health / Stamina / Sanity with threshold callbacks
- `SurvivalProvider` — Riverpod bridge to Flutter HUD
- Sanity threshold effects: vignette, distortion, glitch, hallucination
- `SanityEffectsOverlay` — fullscreen distortion (CustomPainter + animations)

### Added — Progression
- `XpSystem` — formula: `100 × (level ^ 1.4)`, max level 10
- 12 skills: 4 combat, 4 survival, 4 mobility
- `ProgressionProvider` — Riverpod skill state management
- `SkillSelectScreen` — animated 3-card selection

### Added — Level system
- `LevelComponent` — seeded procedural Tiled chunk assembly
- Chapter 1: Ashen Ruins tileset + 8 chunk pool
- Chapter 2: Veil Sanctum tileset + 8 chunk pool
- Safe rooms (Sanity regen), dark zones (Sanity drain), Veil tears

### Added — UI
- `HudOverlay` — animated Health / Stamina / Sanity bars
- `BossHudOverlay` — boss HP bar with phase dots, slide-up animation
- `GameOverScreen` — run stats, XP earned, Try Again / Main Menu
- `ChapterClearScreen` — staggered reward reveal, skin unlock
- `SplashScreen` — animated candle logo, parallel init
- `MainMenuScreen` — animated particle background, nav buttons
- `CharacterSelectScreen` — skin carousel with silhouette previews
- `ChapterSelectScreen` — Chapter cards with lock state
- `SettingsScreen` — volume sliders, accessibility toggles

### Added — IAP & Shop
- `IapService` — `in_app_purchase` wrapper with purchase/restore/deliver
- `CosmeticShopScreen` — 4 skins, buy/equip/lock states
- `ShopProvider` — Riverpod purchase + skin state
- Receipt delivery hook (server-side validation: post-MVP)

### Added — Audio
- `AudioManager` — FlameAudio BGM + SFX singleton
- `AudioProvider` — Riverpod volume settings
- 16 SFX entries, 6 BGM tracks
- Sanity-reactive playback rate + volume shifts

### Added — Save system
- `SaveManager` — SharedPreferences wrapper
- `GameSettings` — master/sfx/music volume, reduce motion, colour-blind
- `GameSettings.copyWith()` — immutable settings update
- Highest chapter, total runs, unlocked skins persistence

### Added — CI/CD
- GitHub Actions: Analyze & Test + Build Android APK + Build iOS
- Coverage gate: 70% line coverage minimum
- Feature branch → develop → main workflow

### Added — Documentation
- Game Design Document v0.1 (15 sections, 561 lines)
- Technical Architecture (4 ADRs)
- Art Design Bible (characters, world, weapons, hit effects)
- QA Regression Checklist (11 sections, 85 test cases)
- Store Listing (iOS + Android copy, ASO, release checklist)

### Fixed (CI pipeline)
- `constants.dart` — `cstatic` typo (line 31)
- `veilborn_game.dart` — missing `dart:flame/camera.dart` import
- `xp_system.dart` — `int` assigned to `double` parameter
- `player_component.dart` — missing `dart:typed_data`, VeilbornGame cast
- `survival_provider.dart` — `ref.notifyListeners()` → `state = state`
- `bosses/ashen_warden.dart` — wrong `../enemy/` relative import prefix
- `bosses/veil_seraph.dart` — 2× wrong `../enemy/` relative import prefix
- `base_enemy_component.dart` — renamed `_ai` → `ai` (Dart privacy)
- `veil_seraph.dart`, `crawler.dart`, `shade.dart` — updated to `ai`

---

## Planned for v1.1.0
- Real sprite art assets integrated
- Cloud save via Firebase
- Leaderboards (daily/all-time)
- Chapter 3: Flooded Crypts
- 20+ enemy types with elite variants
- Crafting / weapon upgrade system

---

*Veilborn Changelog — AI Game Studio*
