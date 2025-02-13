extends Area2D

func is_on_platform():
	var result = _platform_raycast()
	return !result.is_empty()

func get_platform_height():
	# Assums that platform is checked already
	var result = _platform_raycast()
	return result.position.y

func _platform_raycast() -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 100))
	query.set_collision_mask(Constants.PLATFORM_LAYER)
	var result = space_state.intersect_ray(query)
	return result

func _detect_platform():
	return has_overlapping_bodies()
