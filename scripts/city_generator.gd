extends RefCounted
class_name CityGenerator

var rng := RandomNumberGenerator.new()

func generate(world: Node, world_size: Vector2i, ground_line: int) -> void:
	rng.randomize()
	var roads := _build_road_columns(world_size.x)

	for x in world_size.x:
		if x in roads:
			continue

		if rng.randf() > 0.2:
			var floors := rng.randi_range(2, 7)
			_build_tower(world, x, ground_line, floors)

func _build_road_columns(width: int) -> Dictionary:
	var roads := {}
	for x in width:
		if x % 8 == 0 or x % 8 == 1:
			roads[x] = true
	return roads

func _build_tower(world: Node, plot_x: int, ground_line: int, floors: int) -> void:
	var width := rng.randi_range(2, 4)
	for x in range(plot_x, min(plot_x + width, world.world_size_blocks.x)):
		for y in range(ground_line - floors * 2, ground_line):
			if y < 0:
				continue
			var edge := x == plot_x or x == min(plot_x + width, world.world_size_blocks.x) - 1 or y == ground_line - floors * 2
			var block_type := VoxelBlock.BlockType.BRICK if edge else VoxelBlock.BlockType.AIR
			world.set_block(Vector2i(x, y), block_type, false)
