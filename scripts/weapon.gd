class_name Weapon

extends Node2D

@export var weapon_range: float = 2000
@export var damage: float = 5
@export var bullet_path_scene: PackedScene

func fire(pos: Vector2):
	var mouse_position = get_global_mouse_position()

	var space_state = get_world_2d().direct_space_state
	var direction = (mouse_position - pos).normalized()
	var query = PhysicsRayQueryParameters2D.create(pos, pos + (direction * weapon_range))
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	var bullet_path = bullet_path_scene.instantiate() as Line2D
	get_tree().root.add_child(bullet_path)
	bullet_path.add_point(query.from, 0)
	bullet_path.add_point(query.to, 1)
	
	if result.get("collider") != null:
		var hit_collider = result.get("collider") as CollisionObject2D
		for child in hit_collider.get_children():
			if child is Health:
				var hit_object_health = child as Health
				hit_object_health.take_damage(damage)
		
	print("Hit: " + str(result))
