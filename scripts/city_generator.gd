extends RefCounted
class_name CityGenerator

var rng := RandomNumberGenerator.new()

func generate(world: Node, world_size: Vector2i, ground_line: int) -> void:
	rng.randomize()
	var roads := _build_road_columns(world_size.x)

	for x in range(world_size.x):
		if roads.has(x):
			continue

		if rng.randf() > 0.2:
			var floors := rng.randi_range(2, 7)
			_build_tower(world, x, world_size.x, ground_line, floors)

func _build_road_columns(width: int) -> Dictionary:
	var roads := {}
	for x in range(width):
		if x % 8 == 0 or x % 8 == 1:
			roads[x] = true
	return roads

func _build_tower(world: Node, plot_x: int, world_width: int, ground_line: int, floors: int) -> void:
	var tower_width: int = rng.randi_range(2, 4)
	var tower_end: int = mini(plot_x + tower_width, world_width)
	var roof_y: int = ground_line - floors * 2

	for x in range(plot_x, tower_end):
		for y in range(roof_y, ground_line):
			if y < 0:
				continue
			var edge: bool = x == plot_x or x == tower_end - 1 or y == roof_y
			var block_type: int = VoxelBlock.BlockType.BRICK if edge else VoxelBlock.BlockType.AIR
			world.set_block(Vector2i(x, y), block_type, false)
