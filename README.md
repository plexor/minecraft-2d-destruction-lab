# Minecraft-Style 2D Voxel Destruction Lab

A procedural voxel destruction sandbox built in Godot 4, now expanded with game modes, a menu flow, score systems, and chaos events.

## What's new (scaled-up version)

- **Main menu + mode select**
  - Casual Sandbox
  - Challenge (120 second score run)
  - Chaos (timed run + random meteor strikes)
- **HUD + progression-lite loop**
  - live score, blocks remaining, selected tool, and mode timer
  - combo bonus when chaining quick explosions
- **Multiple demolition tools**
  - Small Charge, Demo TNT, Mega Bomb (switch with `1/2/3`)
- **Improved startup visibility**
  - world auto-fits to the camera view so terrain and city structures are visible immediately

## Project configuration

- **Engine:** Godot 4
- **Type:** 2D voxel destruction sandbox
- **Block size:** 32
- **Chunk size:** 16
- **Base world size:** starts at 8x4 chunks and scales by mode
- **Block palette:** air, dirt, stone, brick
- **Debris body:** `RigidBody2D`
- **Debris cap:** mode-dependent

## Key systems

- chunk-based voxel world
- dynamic block destruction
- flood-fill structural collapse detection
- physics debris simulation
- procedural city generator
- mode manager (`scripts/game_manager.gd`) for menu, scoring, timers, and events

## Controls

- **Left click:** use selected explosive tool
- **Right click:** place brick block
- **1 / 2 / 3:** switch demolition tools
- **R:** return to menu
- **S:** toggle slow motion

## Scripts

- `scripts/voxel_world.gd`
- `scripts/voxel_chunk.gd`
- `scripts/voxel_block.gd`
- `scripts/game_manager.gd`
- `scripts/explosion_system.gd` (legacy helper)
- `scripts/physics_debris.gd`
- `scripts/city_generator.gd`
