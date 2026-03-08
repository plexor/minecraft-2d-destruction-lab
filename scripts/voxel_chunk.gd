extends RefCounted
class_name VoxelChunk

var chunk_coord: Vector2i
var chunk_size: int
var blocks: PackedInt32Array

func _init(coord: Vector2i, size: int) -> void:
	chunk_coord = coord
	chunk_size = size
	blocks = PackedInt32Array()
	blocks.resize(chunk_size * chunk_size)

func index(local: Vector2i) -> int:
	return local.y * chunk_size + local.x

func in_bounds(local: Vector2i) -> bool:
	return local.x >= 0 and local.y >= 0 and local.x < chunk_size and local.y < chunk_size

func get_block(local: Vector2i) -> int:
	if not in_bounds(local):
		return VoxelBlock.BlockType.AIR
	return blocks[index(local)]

func set_block(local: Vector2i, block_type: int) -> void:
	if not in_bounds(local):
		return
	blocks[index(local)] = block_type
