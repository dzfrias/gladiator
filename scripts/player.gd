extends CharacterBody2D

@export var move_speed : float = 10000
@export var jump_speed : float = 500

@export var weapon_range : float = 2000
@export var damage : float = 5
@export var bullet_path_scene : PackedScene

func _process(delta: float) -> void:
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		velocity.x = 0
	elif Input.is_action_pressed("left"):
		velocity.x = -move_speed * delta
	elif Input.is_action_pressed("right"):
		velocity.x = move_speed * delta
	else:
		velocity.x = 0
	
	velocity.y += get_gravity().y * delta
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = -jump_speed
		
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		var mouse_position = get_global_mouse_position()

		var space_state = get_world_2d().direct_space_state
		var direction = (mouse_position - global_position).normalized()
		var query = PhysicsRayQueryParameters2D.create(position, position + (direction * weapon_range))
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
