class_name HitParticles extends Node2D

@export var impact_particle_scene: PackedScene = preload("res://scenes/particles/impact_particles.tscn")

func _ready() -> void:
	var health: Health
	for child in get_parent().get_children():
		if child is Health:
			health = child
	health.damage_taken.connect(_on_health_damage_taken)

func _on_health_damage_taken(_amount: float, direction: Vector2) -> void:
	var impact_particles = impact_particle_scene.instantiate()
	impact_particles.global_position = global_position
	get_tree().current_scene.add_child(impact_particles)
	impact_particles.direction = direction
	impact_particles.emitting = true
