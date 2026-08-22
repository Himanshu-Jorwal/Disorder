# Zenith

A top-down survival game I'm building in Godot 4 during my summer break.

Still early days but the core loop is working — you move, shoot, enemies come at you, and you try to survive as long as possible. There's a mechanic at the center of the game that I'm pretty excited about but I'll talk more about that when it's further along.

## Stack

- Godot 4 — first time using it, picking it up as I go
- GDScript
- Everything drawn in code for now, no art assets yet

## Project Structure

Zenith-0.0.0/
├── Scenes/
│ ├── Game/
│ ├── UI/
│ └── Menu/
├── Scripts/
│ ├── Game/
│ ├── UI/
│ ├── Menu/
│ └── World/
└── project.godot

## How to run it

You'll need Godot 4 — grab it from [godotengine.org](https://godotengine.org/download)

```bash
git clone https://github.com/Himanshu-Jorwal/Zenith.git
```

Then open Godot, hit Import, find `Zenith-0.0.0/project.godot` and open it. Press F5 to run.

## Controls

| Action | Key |
|--------|-----|
| Move | WASD |
| Aim | Mouse |
| Shoot | Automatic |
| Pause | ESC |
| Fullscreen | F11 |

## What's in so far

- Movement, shooting, camera follow
- Enemies that chase and damage you
- Health, XP and leveling
- Upgrade choices when you level up
- A moon phase system that changes how the game plays over time
- Dynamic world border
- HUD, main menu, pause menu, game over screen

## What's coming

- More enemy types
- Bosses
- Character selection
- A lot more depth to the moon system
- Actual art (eventually)
- Web build on itch.io

## Notes

Third year CS student. First game. Learning Godot from scratch while building this.
Updates whenever I have time to sit down and work on it.