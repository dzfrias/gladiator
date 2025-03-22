extends Node

@export var land_impact_particles_prefab: PackedScene

var _particle_impact_threshold = 350
var _impact_particle_multiplier = 0.025
var _impact_speed_particle_multiplier = 0.1

func _ready() -> void:
	get_parent().on_ground_impact.connect(_on_ground_impact)

func _on_ground_impact(impact_force: float):
	if impact_force < _particle_impact_threshold:
		return
	var land_impact_particles = land_impact_particles_prefab.instantiate() as CPUParticles2D
	get_tree().current_scene.add_child(land_impact_particles)
	land_impact_particles.global_position = get_parent().global_position
	land_impact_particles.amount = impact_force * _impact_particle_multiplier
	land_impact_particles.initial_velocity_max += impact_force * _impact_speed_particle_multiplier
	land_impact_particles.emitting = true
	await land_impact_particles.finished
	land_impact_particles.queue_free()
