extends Node

@export var land_impact_particles_scene: PackedScene = preload("res://scenes/particles/land_impact_particles.tscn")
@export var step_interval: float = 0.2

var _player: Player
var _player_underground_particles: CPUParticles2D
var _particle_impact_threshold = 350
var _impact_particle_multiplier = 0.025
var _impact_speed_particle_multiplier = 0.1
@onready var _step_timer := step_interval
var _bottom: Vector2

func _ready() -> void:
	_player = get_parent() as Player
	_player.on_ground_impact.connect(_on_ground_impact)
	_player.jumped.connect(_on_jump)
	var player_rect := _player.hitbox().shape.get_rect()
	_bottom = Vector2(player_rect.end.x - player_rect.size.x / 2, player_rect.end.y)
	_player_underground_particles = _player.find_child("UndergroundParticles")

func _on_ground_impact(impact_force: float):
	if impact_force < _particle_impact_threshold:
		return
	_spawn_impact_particles(impact_force * _impact_particle_multiplier, impact_force * _impact_speed_particle_multiplier)

func _on_jump() -> void:
	_spawn_impact_particles(30, 12.0)

func _process(delta: float) -> void:
	if absf(_player.velocity.x) > 0 and _player.is_on_floor() and not _player.is_underground():
		_step_timer -= delta
	else:
		_step_timer = step_interval
	
	if _step_timer <= 0:
		_step_timer = step_interval
		_spawn_impact_particles(10, 8.0)
	
	_player_underground_particles.emitting = _player.is_underground()

func _spawn_impact_particles(amount: int, initial_velocity_delta: float) -> void:
	var land_impact_particles := land_impact_particles_scene.instantiate() as CPUParticles2D
	get_tree().current_scene.add_child(land_impact_particles)
	land_impact_particles.global_position = _player.to_global(_bottom)
	land_impact_particles.amount = amount
	land_impact_particles.initial_velocity_max += initial_velocity_delta
	land_impact_particles.emitting = true
	await land_impact_particles.finished
	land_impact_particles.queue_free()
