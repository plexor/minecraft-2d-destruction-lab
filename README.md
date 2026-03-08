# Minecraft-Style 2D Voxel Destruction Lab

A procedural voxel destruction sandbox built in Godot 4.

Blocks exist in a grid system similar to Minecraft. Explosions remove blocks in real time, unsupported structures collapse into physics debris, and a procedural city generator creates destructible urban skylines on top of the terrain.

## Project configuration

- **Engine:** Godot 4
- **Type:** 2D voxel destruction sandbox
- **Block size:** 32
- **Chunk size:** 16
- **World size:** 8x4 chunks
- **Block palette:** air, dirt, stone, brick
- **Explosion radius:** 5
- **Explosion force:** 2000
- **Debris body:** `RigidBody2D`
- **Debris cap:** 200 pieces

## Key systems

- chunk-based voxel world
- dynamic block destruction
- flood-fill structural collapse detection
- physics debris simulation
- procedural city generator

## Controls

- **Left click:** spawn explosion
- **Right click:** place block
- **R:** reset world
- **S:** toggle slow motion

## Scripts

- `scripts/voxel_world.gd`
- `scripts/voxel_chunk.gd`
- `scripts/voxel_block.gd`
- `scripts/explosion_system.gd`
- `scripts/physics_debris.gd`
- `scripts/city_generator.gd`
