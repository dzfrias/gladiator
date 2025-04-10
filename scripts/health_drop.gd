class_name HealthDrop extends StaticBody2D

@export var heal_amount: float = 4.0
@export var acceleration_factor: float = 1.03
@export var initial_velocity: float = 100.0
@export var max_velocity: float = 500.0

@onready var _velocity: Vector2 = Vector2.RIGHT * initial_velocity
@onready var _tracking: Node2D = Player.Instance

func _physics_process(delta: float) -> void:
	var angle := get_angle_to(_tracking.position)
	_velocity = _velocity.rotated(angle) * acceleration_factor
	_velocity = _velocity.limit_length(max_velocity)
	
	var collision := move_and_collide(_velocity * delta)
	_velocity = _velocity.rotated(-angle)
	if collision != null and collision.get_collider() is Player:
		var player := collision.get_collider()
		player.get_health().heal(heal_amount)
		queue_free()
