class_name TileMapParticles extends TileMapLayer

@export var impact_particle_prefab: PackedScene

func hit_tilemap(impact_position: Vector2, direction: Vector2):
	var impact_particles = impact_particle_prefab.instantiate()
	impact_particles.global_position = impact_position
	get_tree().current_scene.add_child(impact_particles)
	impact_particles.direction = -direction
	impact_particles.emitting = true
	await impact_particles.finished
	impact_particles.queue_free()
