extends Area2D

func is_on_platform():
	return $RayCast2D.is_colliding()

func get_platform_height():
	return $RayCast2D.get_collision_point().y

func is_detecting_platform():
	return has_overlapping_bodies()
