# Veilborn — Manual QA Regression Checklist
**Version:** 1.0 | **Phase:** 8 — QA & Release | **Jira:** KAN-5
**Run before every:** PR merge to develop · Release candidate build

---

## 🔧 Test Environment
- **iOS device:** iPhone 12 (iOS 16+) — primary
- **iOS simulator:** iPhone 15 Pro (iOS 17) — CI
- **Android device:** Mid-range 2022 (Snapdragon 765G, API 33) — primary
- **Android emulator:** Pixel 7 API 33 — CI
- **Screen sizes tested:** 375pt, 390pt, 430pt (iPhone), 360dp, 412dp (Android)

---

## ✅ Section 1 — App Launch & Navigation

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 1.1 | Cold launch from icon | Splash screen → Main Menu in <3s | ☐ | ☐ | |
| 1.2 | Main Menu loads all buttons | Play / Skins / Settings visible | ☐ | ☐ | |
| 1.3 | Tap Play → Character Select | Transition animates, skins load | ☐ | ☐ | |
| 1.4 | Swipe carousel left/right | Skins switch with page dots | ☐ | ☐ | |
| 1.5 | Back button returns correctly | iOS swipe / Android back button | ☐ | ☐ | |
| 1.6 | Tap Play → Chapter Select | Chapter cards visible, Ch2 locked | ☐ | ☐ | |
| 1.7 | Tap Chapter 1 → Game loads | Black canvas then game starts | ☐ | ☐ | |
| 1.8 | Settings screen opens | All sliders + toggles present | ☐ | ☐ | |

---

## ✅ Section 2 — Player Movement

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 2.1 | Left/right joystick movement | Player moves smoothly at 60fps | ☐ | ☐ | |
| 2.2 | Jump button | Player jumps, arc feels responsive | ☐ | ☐ | |
| 2.3 | Jump while running | Horizontal momentum preserved | ☐ | ☐ | |
| 2.4 | Coyote time | Jump works 100ms after walking off edge | ☐ | ☐ | |
| 2.5 | Jump buffer | Jump queued 80ms before landing works | ☐ | ☐ | |
| 2.6 | Wall slide | Player slides slowly down walls | ☐ | ☐ | |
| 2.7 | Wall jump | Jump off wall with direction reversal | ☐ | ☐ | |
| 2.8 | Dash | Brief burst, I-frames active | ☐ | ☐ | Opacity flicker visible |
| 2.9 | Dash stamina cost | Stamina bar depletes by 25 | ☐ | ☐ | |
| 2.10 | No dash with empty stamina | Dash button does nothing | ☐ | ☐ | |

---

## ✅ Section 3 — Combat

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 3.1 | Light attack | Single hit, 10 dmg | ☐ | ☐ | |
| 3.2 | Light × 3 combo | Combo finisher fires (40 dmg AoE) | ☐ | ☐ | |
| 3.3 | Heavy attack | 25 dmg + knockback | ☐ | ☐ | |
| 3.4 | Heavy without stamina | Does nothing | ☐ | ☐ | |
| 3.5 | Ranged attack | Projectile spawns + travels | ☐ | ☐ | |
| 3.6 | I-frames after hit | Second hit within 0.8s does no damage | ☐ | ☐ | |
| 3.7 | Hit flash effect | Player flashes on damage received | ☐ | ☐ | |
| 3.8 | Enemy takes damage | HP reduces, hit flash visible | ☐ | ☐ | |
| 3.9 | Enemy death | Enemy fades out, soul essence drops | ☐ | ☐ | |

---

## ✅ Section 4 — Survival System (Health / Stamina / Sanity)

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 4.1 | Health bar depletes on hit | Red bar animates down | ☐ | ☐ | |
| 4.2 | Health at 25% — bar glows | Red glow effect visible | ☐ | ☐ | |
| 4.3 | Stamina depletes on dash | Teal bar drops by 25 | ☐ | ☐ | |
| 4.4 | Stamina regenerates | Bar refills after 1.5s idle | ☐ | ☐ | |
| 4.5 | Sanity depletes in dark zone | White bar drops at −5/s | ☐ | ☐ | |
| 4.6 | Sanity at 74 — vignette appears | Dark edge vignette fades in | ☐ | ☐ | |
| 4.7 | Sanity at 49 — distortion | Enemy sprites distort slightly | ☐ | ☐ | |
| 4.8 | Sanity at 24 — critical | Bar pulses crimson, HUD scrambles | ☐ | ☐ | |
| 4.9 | Sanity restores in safe room | Bar refills at +10/s | ☐ | ☐ | |
| 4.10 | Reduce motion: no distortion | Visual effects absent (only vignette) | ☐ | ☐ | Accessibility |

---

## ✅ Section 5 — Enemy AI

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 5.1 | Wanderer patrol | Enemy walks back and forth | ☐ | ☐ | |
| 5.2 | Wanderer detects player | Chases when within 200px | ☐ | ☐ | |
| 5.3 | Wanderer attacks | Melee lunge, 10 dmg | ☐ | ☐ | |
| 5.4 | Wraith floats | Sinusoidal Y oscillation | ☐ | ☐ | |
| 5.5 | Wraith sanity drain | Sanity drops on hit | ☐ | ☐ | |
| 5.6 | Crawler ceiling movement | Crawls on ceiling, drops on player | ☐ | ☐ | |
| 5.7 | Shade teleport | Disappears + reappears | ☐ | ☐ | |
| 5.8 | Shade shadow bolt | Projectile fires, sanity drains | ☐ | ☐ | |
| 5.9 | Husk ground slam | AoE indicator appears | ☐ | ☐ | |
| 5.10 | All enemies retreat at 20% HP | Enemy backs away | ☐ | ☐ | |

---

## ✅ Section 6 — Boss Fights

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 6.1 | Ashen Warden spawns | Boss HUD slides up | ☐ | ☐ | |
| 6.2 | Warden Phase 1 attacks | Melee combo + ground slam | ☐ | ☐ | |
| 6.3 | Warden Phase 2 trigger | Phase shift at 50% HP | ☐ | ☐ | Flash + shake |
| 6.4 | Warden Phase 2 projectiles | Spread fan fires | ☐ | ☐ | |
| 6.5 | Warden defeat | Chapter clear screen appears | ☐ | ☐ | |
| 6.6 | Veil Seraph spawns | Boss floats, never touches ground | ☐ | ☐ | |
| 6.7 | Seraph Phase 2 | Wraiths summoned every 20s | ☐ | ☐ | |
| 6.8 | Seraph Phase 3 | Reality distortion overlay active | ☐ | ☐ | |
| 6.9 | Seraph defeat | Ch2 clear + credits trigger | ☐ | ☐ | |

---

## ✅ Section 7 — Progression & Economy

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 7.1 | XP gain from kills | XP bar visible (post-UI impl) | ☐ | ☐ | |
| 7.2 | Level up trigger | Skill select screen appears | ☐ | ☐ | |
| 7.3 | Skill select shows 3 cards | Cards unique, no duplicates | ☐ | ☐ | |
| 7.4 | Skill selection applies | Skill effect active rest of run | ☐ | ☐ | |
| 7.5 | Iron Will: HP +25 | Max health increases | ☐ | ☐ | |
| 7.6 | Soul Drain: kill = +5 HP | HP restores on enemy kill | ☐ | ☐ | |
| 7.7 | Featherfall: no fall damage | Drop from any height, no damage | ☐ | ☐ | |

---

## ✅ Section 8 — IAP & Shop

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 8.1 | Shop loads skins | 4 skins visible with correct states | ☐ | ☐ | |
| 8.2 | Free skins equippable | Ashen Knight equips without purchase | ☐ | ☐ | |
| 8.3 | IAP skin shows price | Store price loads (sandbox) | ☐ | ☐ | |
| 8.4 | Purchase flow (sandbox) | Payment sheet appears | ☐ | ☐ | Requires dev accounts |
| 8.5 | Purchase delivers skin | Skin unlocked after purchase | ☐ | ☐ | |
| 8.6 | Restore purchases (iOS) | Previously bought skins restore | ☐ | ☐ | iOS only |
| 8.7 | Equipped skin in-game | Character uses selected skin | ☐ | ☐ | |

---

## ✅ Section 9 — Audio

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 9.1 | BGM plays on main menu | Main menu music audible | ☐ | ☐ | |
| 9.2 | BGM transitions on game start | Chapter 1 explore track plays | ☐ | ☐ | |
| 9.3 | SFX on player attack | Attack sound plays | ☐ | ☐ | |
| 9.4 | SFX on enemy death | Death sound plays | ☐ | ☐ | |
| 9.5 | Sanity music distortion | BGM warps at 50% sanity | ☐ | ☐ | |
| 9.6 | BGM pauses when app backgrounds | No audio in background | ☐ | ☐ | iOS/Android |
| 9.7 | Volume sliders work | Audio level changes in real-time | ☐ | ☐ | |
| 9.8 | Volume persists after restart | Saved volume restored on relaunch | ☐ | ☐ | |

---

## ✅ Section 10 — Performance

| # | Test case | Target | iOS | Android | Notes |
|---|---|---|---|---|---|
| 10.1 | Stable FPS — main menu | 60fps constant | ☐ | ☐ | |
| 10.2 | Stable FPS — gameplay | 60fps during combat | ☐ | ☐ | |
| 10.3 | Stable FPS — boss fight | ≥55fps with all boss effects | ☐ | ☐ | |
| 10.4 | Memory — 30 min session | <300MB RAM | ☐ | ☐ | Instruments/Perfetto |
| 10.5 | App size — initial download | <100MB | ☐ | ☐ | |
| 10.6 | Cold launch time | <3 seconds to main menu | ☐ | ☐ | |
| 10.7 | No memory leaks — 5 runs | Memory stable across runs | ☐ | ☐ | |

---

## ✅ Section 11 — Edge Cases & Crash Scenarios

| # | Test case | Expected | iOS | Android | Notes |
|---|---|---|---|---|---|
| 11.1 | App kill + relaunch mid-run | Returns to main menu (run lost) | ☐ | ☐ | |
| 11.2 | Low storage device | Graceful error, no crash | ☐ | ☐ | |
| 11.3 | No internet + IAP tap | Error message shown | ☐ | ☐ | |
| 11.4 | Rapid button spam | No crash, inputs handled | ☐ | ☐ | |
| 11.5 | Player death during boss Phase 3 | Game over screen (no freeze) | ☐ | ☐ | |
| 11.6 | Second sanity zero | Game over triggers correctly | ☐ | ☐ | |
| 11.7 | Chapter 2 locked access attempt | Cannot navigate to Ch2 | ☐ | ☐ | |

---

## 🐛 Bug Priority Matrix

| Priority | Definition | SLA |
|---|---|---|
| **P1 — Blocker** | Crash, data loss, IAP broken, unplayable | Fix before release |
| **P2 — Critical** | Major feature broken, significant wrong behaviour | Fix before release |
| **P3 — High** | Feature partially working, minor wrong behaviour | Fix in v1.0.1 |
| **P4 — Medium** | UI/UX issues, minor glitches | Backlog |
| **P5 — Low** | Cosmetic, very minor | Backlog |

**Release gate: Zero P1 + P2 bugs open.**

---

*Veilborn QA Checklist v1.0 — AI Game Studio — Phase 8*
