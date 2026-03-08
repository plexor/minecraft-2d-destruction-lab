extends RefCounted
class_name VoxelBlock

enum BlockType { AIR, DIRT, STONE, BRICK }

static var COLORS := {
	BlockType.AIR: Color(0, 0, 0, 0),
	BlockType.DIRT: Color("7d5a4f"),
	BlockType.STONE: Color("7e7f87"),
	BlockType.BRICK: Color("b4443d")
}

static func is_solid(block_type: int) -> bool:
	return block_type != BlockType.AIR

static func color_for(block_type: int) -> Color:
	return COLORS.get(block_type, Color.MAGENTA)
