extends Node2D
class_name VoxelWorld

@export var block_size := 32
@export var chunk_size := 16
@export var world_width_chunks := 8
@export var world_height_chunks := 4
@export var max_debris_pieces := 200
@export var collapse_disconnected := true
@export var auto_fit_world_to_view := true

var world_size_blocks := Vector2i.ZERO
var chunks := {}
var debris_root: Node2D
var city_generator := CityGenerator.new()

func _ready() -> void:
	world_size_blocks = Vector2i(world_width_chunks * chunk_size, world_height_chunks * chunk_size)
	debris_root = Node2D.new()
	debris_root.name = "Debris"
	add_child(debris_root)
	reset_world()
	if auto_fit_world_to_view:
		_fit_world_to_view()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_block"):
		set_block(global_to_grid(get_global_mouse_position()), VoxelBlock.BlockType.BRICK)
	if event.is_action_pressed("reset_world"):
		reset_world()
		if auto_fit_world_to_view:
			_fit_world_to_view()
	if event.is_action_pressed("slow_motion"):
		Engine.time_scale = 0.2 if Engine.time_scale > 0.2 else 1.0

func reset_world() -> void:
	chunks.clear()
	for child in debris_root.get_children():
		child.queue_free()

	for cy in world_height_chunks:
		for cx in world_width_chunks:
			var coord := Vector2i(cx, cy)
			chunks[coord] = VoxelChunk.new(coord, chunk_size)

	_generate_terrain()
	city_generator.generate(self, world_size_blocks, int(world_size_blocks.y * 0.6))
	queue_redraw()


func _fit_world_to_view() -> void:
	var viewport_size := get_viewport_rect().size
	var ground_line := int(world_size_blocks.y * 0.6)
	var world_ground_y := float(ground_line * block_size)
	var desired_ground_y := viewport_size.y * 0.72
	position = Vector2(0.0, desired_ground_y - world_ground_y)

func _generate_terrain() -> void:
	var ground_line := int(world_size_blocks.y * 0.6)
	for y in world_size_blocks.y:
		for x in world_size_blocks.x:
			var block := VoxelBlock.BlockType.AIR
			if y >= ground_line:
				block = VoxelBlock.BlockType.DIRT
			if y >= ground_line + 5:
				block = VoxelBlock.BlockType.STONE
			set_block(Vector2i(x, y), block, false)

func global_to_grid(world_pos: Vector2) -> Vector2i:
	var local_pos := to_local(world_pos)
	return Vector2i(floori(local_pos.x / block_size), floori(local_pos.y / block_size))

func grid_to_global(grid: Vector2i) -> Vector2:
	var local_pos := Vector2((grid.x + 0.5) * block_size, (grid.y + 0.5) * block_size)
	return to_global(local_pos)

func get_block(grid: Vector2i) -> int:
	var chunk_coord := Vector2i(floori(float(grid.x) / chunk_size), floori(float(grid.y) / chunk_size))
	var local := Vector2i(posmod(grid.x, chunk_size), posmod(grid.y, chunk_size))
	var chunk: VoxelChunk = chunks.get(chunk_coord)
	if chunk == null:
		return VoxelBlock.BlockType.AIR
	return chunk.get_block(local)

func set_block(grid: Vector2i, block_type: int, redraw := true) -> void:
	if grid.x < 0 or grid.y < 0 or grid.x >= world_size_blocks.x or grid.y >= world_size_blocks.y:
		return

	var chunk_coord := Vector2i(floori(float(grid.x) / chunk_size), floori(float(grid.y) / chunk_size))
	var local := Vector2i(posmod(grid.x, chunk_size), posmod(grid.y, chunk_size))
	var chunk: VoxelChunk = chunks.get(chunk_coord)
	if chunk == null:
		return
	chunk.set_block(local, block_type)
	if redraw:
		queue_redraw()

func apply_explosion(world_pos: Vector2, radius: int, force: float) -> void:
	var center := global_to_grid(world_pos)
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var p := Vector2i(x, y)
			if p.distance_to(center) <= radius and VoxelBlock.is_solid(get_block(p)):
				_spawn_debris(p, force, world_pos)
				set_block(p, VoxelBlock.BlockType.AIR, false)

	if collapse_disconnected:
		collapse_floating_sections()
	queue_redraw()

func collapse_floating_sections() -> void:
	var visited := {}
	var q: Array[Vector2i] = []
	for x in world_size_blocks.x:
		var p := Vector2i(x, world_size_blocks.y - 1)
		if VoxelBlock.is_solid(get_block(p)):
			q.append(p)
			visited[p] = true

	var directions: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	while not q.is_empty():
		var current: Vector2i = q.pop_front()
		for dir in directions:
			var n: Vector2i = current + dir
			if visited.has(n):
				continue
			if not VoxelBlock.is_solid(get_block(n)):
				continue
			visited[n] = true
			q.append(n)

	for y in world_size_blocks.y:
		for x in world_size_blocks.x:
			var p := Vector2i(x, y)
			if VoxelBlock.is_solid(get_block(p)) and not visited.has(p):
				_spawn_debris(p, 350.0, grid_to_global(p))
				set_block(p, VoxelBlock.BlockType.AIR, false)

func _spawn_debris(grid: Vector2i, force: float, explosion_origin: Vector2) -> void:
	if debris_root.get_child_count() >= max_debris_pieces:
		return

	var body := PhysicsDebris.new()
	body.position = grid_to_global(grid)

	var sprite := Polygon2D.new()
	var half := float(block_size) * 0.5
	sprite.polygon = PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half)
	])
	sprite.color = VoxelBlock.color_for(get_block(grid))
	body.add_child(sprite)

	var collider := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(block_size, block_size)
	collider.shape = rect
	body.add_child(collider)

	debris_root.add_child(body)
	var impulse_dir := (body.position - explosion_origin).normalized()
	body.apply_central_impulse(impulse_dir * force)

func _draw() -> void:
	for y in world_size_blocks.y:
		for x in world_size_blocks.x:
			var block := get_block(Vector2i(x, y))
			if block == VoxelBlock.BlockType.AIR:
				continue
			draw_rect(
				Rect2(Vector2(x * block_size, y * block_size), Vector2.ONE * block_size),
				VoxelBlock.color_for(block),
				true
			)
