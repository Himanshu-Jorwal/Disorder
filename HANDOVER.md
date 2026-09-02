# Zenith — Project Handover Document

## Project Overview
Top-down survival game built in Godot 4 using GDScript.
Core mechanic: Moon phases cycle every 60 seconds and alter enemy behavior, spawn rates and boss encounters.
Goal: Survive as long as possible.

## Technical Stack
- Engine: Godot 4 (Compatibility renderer for web export)
- Language: GDScript
- Repo: github.com/Himanshu-Jorwal/Zenith
- Project folder: `Zenith Dev Kit/Zenith-0.0.0/`

## Project Structure

Zenith-0.0.0/
├── Assets/
│ ├── Characters/ # zaire.png, daggers.png, milano.png (300x300 AI generated)
│ └── HUD/ # Heart.png (32x32 hand made)
├── Scenes/
│ ├── Game/
│ │ ├── Mobs/ # All enemy/boss scenes
│ │ ├── bullet.tscn
│ │ ├── rift.tscn # Milano Rift ability
│ │ ├── beam.tscn # Milano old beam (replaced)
│ │ ├── daggers_shadow.tscn # Daggers Mirror ability
│ │ └── daggers_press.tscn # Daggers Absolute ability
│ ├── UI/
│ │ ├── hud.tscn
│ │ ├── upgrade_menu.tscn
│ │ ├── game_over.tscn
│ │ ├── pause_menu.tscn
│ │ └── damage_number.tscn
│ └── Menu/
│ ├── bootstrap.tscn # Entry point, loads main_menu
│ ├── main_menu.tscn
│ └── character_select.tscn
├── Scripts/
│ ├── Game/
│ │ ├── Mobs/ # All enemy/boss scripts
│ │ ├── player.gd
│ │ ├── bullet.gd
│ │ ├── world.gd
│ │ ├── background.gd
│ │ ├── daggers_shadow.gd
│ │ └── daggers_press.gd
│ ├── UI/
│ │ ├── hud.gd
│ │ ├── hud_draw.gd # All HUD drawing done here
│ │ ├── upgrade_menu.gd
│ │ ├── game_over.gd
│ │ ├── pause_menu.gd
│ │ └── damage_number.gd
│ ├── Menu/
│ │ ├── main_menu.gd
│ │ ├── menu_draw.gd # Main menu drawn in code
│ │ ├── character_select.gd
│ │ └── select_draw.gd # Character select drawn in code
│ └── World/
│ ├── moon_phase_manager.gd
│ ├── background.gd
│ └── moon.gd
├── Scripts/game_state.gd # Autoload — stores selected character
└── project.godot


## Autoloads
- `GameState` — `Scripts/game_state.gd` — stores `selected_character` index (0=Zaire, 1=Daggers, 2=Milano)

## Scene Flow
bootstrap.tscn → main_menu.tscn → character_select.tscn → world.tscn

## World Scene Tree

World (Node2D) — world.gd
├── Background (Node2D) — background.gd (stars, deep space)
├── WorldBorder (StaticBody2D) — world_border.gd
├── Player (CharacterBody2D) — player.gd
├── MoonPhaseManager (Node) — moon_phase_manager.gd
├── HUD (CanvasLayer) — hud.gd
│ ├── HUDDraw (Node2D) — hud_draw.gd
│ └── Moon (Node2D) — moon.gd
├── UpgradeMenu (CanvasLayer) — upgrade_menu.gd
├── GameOver (CanvasLayer) — game_over.gd
└── PauseMenu (CanvasLayer) — pause_menu.gd


## Key Systems

### Moon Phase System (moon_phase_manager.gd)
6 phases cycling every 60 seconds:
- 0: CRESCENT — baseline
- 1: HALF — faster spawns
- 2: FULL — Graven spawns
- 3: BLOOD — Malakar spawns, fastest spawns
- 4: BLUE — slower spawns, Lark buffed
- 5: NEW — Lark more dangerous

Signals: `phase_changed(phase)`, `cycle_completed(cycle_number)`
`paused = true` during Lilith fight.

### World Border (world_border.gd)
- Arena size: 3000x2000
- Dark purple animated force field
- Proximity detection: turns heat spectrum (red→orange→yellow→white) when player approaches
- Corner mechanical pillars with L-shaped arms
- Built using `StaticBody2D` with 4 wall children created in code

### Player (player.gd)
- Groups: "player"
- HP: 100, max_hp: 100, HP per heart: 20
- BASE_SPEED: 200
- Invincibility: 1.0 sec after hit, flashes
- Screen shake via `trigger_shake(amount, duration)` using Camera2D tween
- Cooldowns: Attack1=0.25s, Attack2=1.0s, Absolute=10.0s
- Character loaded from `GameState.get_character()`

### Bullet System (bullet.gd)
- Type `Area2D`, added to group "bullets"
- Hits enemies by distance check in `_physics_process` (not collision signals)
- Bullet types: "normal", "star", "shard", "lance", "heavy", "tracking", "splitting_shard", "crescent"
- Tracking bullets home toward nearest enemy with `lerp` on direction
- Splitting shards split on timer (0.6s) or on enemy hit

### Enemy Spawning (world.gd)
Spawn rates:
- Wren: 45%
- Feind: 18%
- Mori: 14%
- Lark: 13%
- Kael: 2% (rare)
- Remaining: unused

Difficulty scales every 30 seconds (+0.15).
Spawning stops when `boss_active = true`.

### Boss System (world.gd)
- Graven spawns on Full Moon (phase 2), once per phase
- Malakar spawns on Blood Moon (phase 3), once per phase  
- Lilith spawns after each complete moon cycle
- During Lilith: spawning stops, moon pauses, moon visual hidden
- After Lilith: `lilith_defeated()` resumes everything

## Characters

### Zaire (index 0) — Color: Purple (0.6, 0.3, 1.0)
- LMB **Crossbow**: 3 silver bolts, no tracking, damage 20, spread ±12°
- RMB **Lance**: Single piercing bolt, damage 50, ice blue
- X **Absolute1**: 24 golden tracking bolts in all directions, damage 15 each

### Daggers (index 1) — Color: Teal (0.2, 0.8, 0.7)
- LMB **Shard**: Single shard splits into 3 on hit or after 0.6s, main=20dmg, splits=10dmg
- RMB **Mirror**: Spawns dark shadow clone at player position, attracts enemies, fires attract wave at 2s, detonates at 3s (60 dmg)
- X **Absolute2** (daggers_press): Dash 750px toward mouse, damages(80) and knocks enemies sideways, space rip trail visual, brief invulnerability

### Milano (index 2) — Color: Orange (1.0, 0.5, 0.1) — Female
- LMB **Chime**: Slow heavy orb (speed 200), damage 50, large hitbox
- RMB **Rift**: Creates pull zone at mouse position, pulls enemies for 3 seconds
- X **Absolute3**: Charges 1.5s (concave mirror visual), fires sustained atomic breath beam — blue/white, 1800px range, oval rings along beam, follows mouse, sweeps slowly, damage 5/tick

## Enemies (all in Scenes/Game/Mobs/)

### Normal Enemies
All have: `add_to_group("enemies")`, `apply_phase(phase)`, `apply_difficulty(d)`, `apply_roar_boost()`, `take_damage(amount)`, `die()`

**Wren** — basic chaser, red circle, HP 30, speed 80
**Feind** — telegraphed dasher, orange, HP 25, speed 90 chase / 600 dash, states: CHASE/TELEGRAPH/DASH/RECOVER
**Mori** — growing splitter, purple blob
  - Size 0: tiny fragment, radius 6, speed 150, fades/dies in 10s with arc timer
  - Size 1: default spawn, radius 16, speed 85, grows to size 2 after 25s
  - Size 2: large, radius 36, speed 45
  - On death: size2→2×size1, size1→3×size0, size0→gone
**Lark** — mirror enemy, cyan hexagon
  - Chases when dist>280, orbits 180-280, flees when dist<180
  - Flee speed = player speed + 20 (always faster)
  - Fires projectiles every 3.5s (2.0s during Blue Moon)
  - Blue Moon: faster, more erratic, blue glow
**Kael** — stationary hazard, orange
  - Repulsion field radius 180, force 1200
  - After 20s: leaves corrupt zone (30s duration, 20 dmg/s if entered)
  - Very rare spawn (2%)

### Mini Bosses
**Graven** — Full Moon, gold/yellow hexagon, HP 500, radius 64
  - Ground slam: charges 1.5s then fires 4 SlamRings outward
  - Roar: charges 1s, boosts nearby enemies speed for 5s, RoarWave visual
  - Summons Wrens every 8s
  - Enrages at 50% HP: speed doubles, red X, faster slam/roar, summons Feinds

**Malakar** — Blood Moon, dark red blob, HP 400, radius 40
  - Devours nearby normal enemies (not bosses), heals 40 HP, gains speed, cooldown 3s
  - Stored devours shown as orbiting orbs
  - Blood surge every 8s: charges 1.2s then releases BloodRing expanding outward
  - Enrages at 30%: speed 110, immediate surge

### Boss
**Lilith** — spawns after each complete moon cycle, HP 3000, radius 90
  - Moon pauses, spawning stops during fight
  - Phase 1 (100-66%): orbits player, Lunar Spiral every 12s (24 tracking projectiles), summons mini boss every 20s
  - Phase 2 (66-33%): triple dash with ring after each, twin rings every 8s, spawns Feinds on missed dashes
  - Phase 3 (33-0%): aggressive chase, death spiral every 6s (36 projectiles), spawns Kaels, chaos rings
  - Phase transitions: flash effect + screen shake
  - On death: `world.lilith_defeated()` called, moon resumes

## HUD (hud_draw.gd)
- Hearts: 5 base, each = 20 HP, bonus hearts disappear (don't fade) when damaged
- Heart texture: `Assets/HUD/Heart.png` (32x32)
- XP bar: purple, width = 5 hearts width, bottom has XP text and LVL text
- Ability slots: 3 slots bottom center, show cooldown overlay and timer
- Moon: centered top, changes shape and color per phase, disappears during Lilith

## World Border (world_border.gd)
Colors:
- BASE_COLOR: Color(0.4, 0.1, 0.6, 0.8) — dark purple
- REACT to player proximity: heat spectrum (red→orange→yellow→white)
- Corner pillars: dark steel, L-shaped arms pointing to adjacent corners, teal energy veins

## Upgrade System (upgrade_menu.gd)
Current upgrades (generic, shown on level up):
- Damage +25%
- Fire Rate +25%  
- Move Speed +20%
- Max HP +20

Needs: character specific upgrades (not yet implemented)

## UI Screens Status
- **Main Menu**: Redesigned — drawn in code, dark minimal, grid background, centered ZENITH title, Start/Exit drawn buttons, credits bottom left — DONE
- **Character Select**: Cards with AI art, abilities listed, controls tip box — DONE, good
- **Pause Menu**: Basic — needs redesign
- **Upgrade Screen**: Basic — needs redesign  
- **Game Over Screen**: Basic — needs redesign
- **HUD**: Good — hearts, XP bar, ability slots, moon — mostly done

## What's Next (Priority Order)
1. Redesign Pause Menu, Upgrade Screen, Game Over Screen (same dark minimal style as main menu)
2. Upgrade system — add character specific upgrades
3. Sound effects
4. Web export to itch.io
5. Balance pass (best with tester feedback)
6. Character/enemy sprites (LibreSprite work in progress)
7. Settings menu
8. Credits screen

## Key Technical Notes
- All UI drawn in code using `_draw()` on Node2D — no Godot UI nodes for visuals
- Buttons detected via `_input` and `Rect2.has_point()` — not Godot Button nodes (except old screens)
- Enemy hit detection via distance check in bullet `_physics_process` — not collision signals
- Collision layers: player=1, enemies=2, bullets=3
- Arena bounds: x clamp -1450 to 1450, y clamp -950 to 950
- All enemies share group "enemies", bosses also in "bosses"
- Bullets in group "bullets" for Lilith hitbox detection
- `process_mode = ALWAYS` on UI nodes that work while paused