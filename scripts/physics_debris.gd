extends RigidBody2D
class_name PhysicsDebris

@export var lifetime := 3.5

func _ready() -> void:
	gravity_scale = 1.0
	mass = 0.3
	contact_monitor = false

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()
