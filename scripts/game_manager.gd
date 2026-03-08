extends Node2D
class_name GameManager

@export var world_path: NodePath = NodePath("VoxelWorld")
@export var menu_panel_path: NodePath = NodePath("UI/MenuPanel")
@export var hud_panel_path: NodePath = NodePath("UI/HUD")
@export var mode_label_path: NodePath = NodePath("UI/HUD/VBox/ModeLabel")
@export var timer_label_path: NodePath = NodePath("UI/HUD/VBox/TimerLabel")
@export var score_label_path: NodePath = NodePath("UI/HUD/VBox/ScoreLabel")
@export var tool_label_path: NodePath = NodePath("UI/HUD/VBox/ToolLabel")
@export var hint_label_path: NodePath = NodePath("UI/HUD/VBox/HintLabel")

var world: VoxelWorld
var menu_panel: Control
var hud_panel: Control
var mode_label: Label
var timer_label: Label
var score_label: Label
var tool_label: Label
var hint_label: Label

var game_active := false
var current_mode := ""
var score := 0
var time_left := 0.0
var selected_tool := 0
var combo := 1
var last_explosion_time := -10.0

var game_timer: Timer
var chaos_timer: Timer

var tool_defs := [
	{"name": "Small Charge", "radius": 3, "force": 1100.0},
	{"name": "Demo TNT", "radius": 5, "force": 2000.0},
	{"name": "Mega Bomb", "radius": 8, "force": 2800.0}
]

var mode_defs := {
	"Casual": {"size": Vector2i(8, 4), "time": 0.0, "debris": 220, "chaos": false},
	"Challenge": {"size": Vector2i(12, 5), "time": 120.0, "debris": 260, "chaos": false},
	"Chaos": {"size": Vector2i(14, 6), "time": 90.0, "debris": 320, "chaos": true}
}

func _ready() -> void:
	world = get_node(world_path)
	menu_panel = get_node(menu_panel_path)
	hud_panel = get_node(hud_panel_path)
	mode_label = get_node(mode_label_path)
	timer_label = get_node(timer_label_path)
	score_label = get_node(score_label_path)
	tool_label = get_node(tool_label_path)
	hint_label = get_node(hint_label_path)

	game_timer = Timer.new()
	game_timer.wait_time = 1.0
	game_timer.autostart = false
	game_timer.timeout.connect(_on_game_tick)
	add_child(game_timer)

	chaos_timer = Timer.new()
	chaos_timer.wait_time = 2.5
	chaos_timer.autostart = false
	chaos_timer.timeout.connect(_on_chaos_tick)
	add_child(chaos_timer)

	show_main_menu()

func show_main_menu() -> void:
	game_active = false
	menu_panel.visible = true
	hud_panel.visible = true
	game_timer.stop()
	chaos_timer.stop()

	mode_label.text = "Mode: MENU"
	timer_label.text = "Timer: --"
	score_label.text = "Score: 0"
	tool_label.text = "Tool: %s" % tool_defs[selected_tool].name
	hint_label.text = "Pick a mode: Casual / Challenge / Chaos"

func start_mode(mode_name: String) -> void:
	var config: Dictionary = mode_defs.get(mode_name, {})
	if config.is_empty():
		return

	current_mode = mode_name
	score = 0
	combo = 1
	selected_tool = 1
	last_explosion_time = -10.0
	time_left = float(config.get("time", 0.0))

	var size: Vector2i = config.get("size", Vector2i(8, 4))
	var debris: int = int(config.get("debris", 220))
	world.configure_world(size.x, size.y, debris)

	game_active = true
	menu_panel.visible = false
	if time_left > 0.0:
		game_timer.start()
	else:
		game_timer.stop()

	if bool(config.get("chaos", false)):
		chaos_timer.start()
	else:
		chaos_timer.stop()

	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_world"):
		show_main_menu()
		return

	if not game_active:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_1:
			selected_tool = 0
			_update_hud()
		if event.physical_keycode == KEY_2:
			selected_tool = 1
			_update_hud()
		if event.physical_keycode == KEY_3:
			selected_tool = 2
			_update_hud()

	if event.is_action_pressed("spawn_explosion"):
		_fire_explosion(get_global_mouse_position())
	if event.is_action_pressed("place_block"):
		world.set_block(world.global_to_grid(get_global_mouse_position()), VoxelBlock.BlockType.BRICK)
	if event.is_action_pressed("slow_motion"):
		Engine.time_scale = 0.2 if Engine.time_scale > 0.2 else 1.0

func _fire_explosion(world_pos: Vector2) -> void:
	var tool: Dictionary = tool_defs[selected_tool]
	var now := Time.get_ticks_msec() / 1000.0
	combo = 2 if now - last_explosion_time < 1.0 else 1
	last_explosion_time = now

	var removed := world.apply_explosion(world_pos, int(tool["radius"]), float(tool["force"]))
	score += removed * 10 * combo
	_update_hud()

func _on_game_tick() -> void:
	if not game_active:
		return
	time_left = max(time_left - 1.0, 0.0)
	if time_left <= 0.0:
		end_run()
	_update_hud()

func _on_chaos_tick() -> void:
	if not game_active:
		return

	var center := Vector2(
		randf_range(0.0, world.world_size_blocks.x * world.block_size),
		randf_range(0.0, world.world_size_blocks.y * world.block_size)
	)
	var global_center := world.to_global(center)
	world.apply_explosion(global_center, 4, 1500.0)
	hint_label.text = "Chaos event: meteor strike!"

func end_run() -> void:
	game_active = false
	game_timer.stop()
	chaos_timer.stop()
	menu_panel.visible = true
	hint_label.text = "Run ended! Final score: %d" % score

func _update_hud() -> void:
	mode_label.text = "Mode: %s" % current_mode
	timer_label.text = "Timer: ∞" if time_left <= 0.0 else "Timer: %ds" % int(time_left)
	score_label.text = "Score: %d | Blocks Left: %d" % [score, world.get_solid_block_count()]
	tool_label.text = "Tool: %s (1/2/3)" % tool_defs[selected_tool].name
	if combo > 1:
		hint_label.text = "Combo x%d! Chain explosions for bonus points." % combo
	else:
		hint_label.text = "LMB: explode | RMB: place brick | R: menu | S: slow motion"

func _on_casual_pressed() -> void:
	start_mode("Casual")

func _on_challenge_pressed() -> void:
	start_mode("Challenge")

func _on_chaos_pressed() -> void:
	start_mode("Chaos")
