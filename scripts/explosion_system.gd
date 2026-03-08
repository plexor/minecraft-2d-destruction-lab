extends Node2D
class_name ExplosionSystem

@export var world_path: NodePath
@export var explosion_radius := 5
@export var explosion_force := 2000.0

var world: Node

func _ready() -> void:
	world = get_node_or_null(world_path)

func _unhandled_input(event: InputEvent) -> void:
	if world == null:
		return

	if event.is_action_pressed("spawn_explosion"):
		var world_pos := get_global_mouse_position()
		world.apply_explosion(world_pos, explosion_radius, explosion_force)
