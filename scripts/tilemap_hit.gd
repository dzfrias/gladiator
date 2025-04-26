class_name TileMapHit extends HitTarget

@export var hit_particles: PackedScene = preload("res://scenes/particles/impact_particles.tscn")

func hit(pos: Vector2, direction: Vector2, normal: Vector2) -> void:
	var impact_particles = hit_particles.instantiate()
	impact_particles.global_position = pos - normal * 10
	get_tree().current_scene.add_child(impact_particles)
	impact_particles.direction = normal
	impact_particles.emitting = true
	await impact_particles.finished
	impact_particles.queue_free()
