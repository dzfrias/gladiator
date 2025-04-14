class_name HealthDrop extends StaticBody2D

@export var heal_amount: float = 4.0
@export var acceleration_factor: float = 1.03
@export var initial_velocity: float = 100.0
@export var max_velocity: float = 500.0
@export var particles_scene: PackedScene = preload("res://scenes/particles/health_collect_particles.tscn")

@onready var _velocity: Vector2 = Vector2.RIGHT * initial_velocity

func _physics_process(delta: float) -> void:
	var angle := get_angle_to(Player.Instance.position)
	_velocity = _velocity.rotated(angle) * acceleration_factor
	_velocity = _velocity.limit_length(max_velocity)
	
	var collision := move_and_collide(_velocity * delta)
	_velocity = _velocity.rotated(-angle)
	if collision != null and collision.get_collider() is Player:
		var player := collision.get_collider()
		player.get_health().heal(heal_amount)
		var particles := particles_scene.instantiate() as CPUParticles2D
		particles.emitting = true
		get_tree().current_scene.add_child(particles)
		particles.global_position = global_position
		queue_free()
