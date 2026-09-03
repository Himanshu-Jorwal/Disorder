# Disorder

A top-down survival game I'm building in Godot 4 during my summer break.

The world is always night. The moon changes everything.

---

## Stack

- Godot 4 - first time using it, picking it up as I go
- GDScript
- Art - mix of procedural (drawn in code) and AI generated placeholders for now
- Version Control - Git / GitHub

---

## Project Structure

```
Disorder-0.0.1/
├── Assets/
│ ├── Characters/ # Character card art
│ └── HUD/ # HUD textures
├── Scenes/
│ ├── Game/ # Core gameplay scenes and abilities
│ │ └── Mobs/ # All enemy, mini boss and boss scenes
│ ├── UI/ # HUD, upgrade, pause, game over
│ └── Menu/ # Main menu, character select, credits, bootstrap
├── Scripts/
│ ├── Game/ # Player, bullets, world, ability scripts
│ │ └── Mobs/ # All enemy, mini boss and boss scripts
│ ├── UI/ # HUD, upgrade, pause, game over
│ ├── Menu/ # Main menu, character select, credits logic
│ └── World/ # Moon system, background, border
└── project.godot
```

---

## How to run it

You'll need Godot 4 - grab it from [godotengine.org](https://godotengine.org/download)

```bash
git clone https://github.com/Himanshu-Jorwal/Disorder.git
```

Then open Godot, hit Import, find `Disorder-0.0.1/project.godot` and open it. Press F5 to run.

---

## Controls

| Action | Key |
|--------|-----|
| Move | WASD |
| Ability 1 | Left Click |
| Ability 2 | Right Click |
| Absolute | X |
| Pause | ESC |
| Fullscreen | F11 |

---

## Characters

Three playable characters each with unique abilities:

**Zaire** - Precision mage. Silver bolts, piercing lance, tracking nova absolute.

**Daggers** - Phantom assassin. Splitting shards, shadow clone with attract wave, space rip dash absolute.

**Milano** - Heavy controller. Slow knockback orb, gravity rift, atomic sweep beam absolute.

---

## What's in so far

- Top down movement with camera follow
- Three playable characters with unique ability kits
- Moon phase system - 6 phases that alter enemy behavior and spawn rates
- 5 normal enemies with distinct behaviors - Wren, Feind, Mori, Lark, Kael
- 2 mini bosses - Graven (Full Moon), Malakar (Blood Moon)
- Boss - Lilith, spawns after a full moon cycle with 3 phases
- Dynamic world border with reactive force field
- XP and leveling with upgrade system
- Hearts based HP display
- Ability cooldown indicators on HUD
- Main menu, character select, pause menu, upgrade menu, game over screen, and a credits screen - all sharing one consistent dark, minimal, code-drawn UI style
- Screen shake on damage
- Fullscreen support

---

## What's coming

- Milano ability improvements
- Character specific upgrades
- Balance pass
- Sound effects
- Enemy and character sprites
- Settings menu
- Web build on itch.io

---

## Notes

Third year CS student. First game. Learning Godot from scratch while building this.
Updates whenever I have time to sit down and work on it.
