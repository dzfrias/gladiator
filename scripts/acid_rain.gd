extends RayCast2D

@export var debug_line: Line2D
@export var time_between_damage: float = 1
@export var damage: float = 2

var can_damage: bool = true

func _process(delta: float) -> void:
	global_position.x = Player.Instance.global_position.x

	move_debug_line()
	if is_colliding():
		var collider = get_collider()
		if collider is Player and can_damage:
			var player = collider as Player
			player.damage(damage)
			damage_cooldown()

func damage_cooldown():
	can_damage = false
	await get_tree().create_timer(time_between_damage).timeout
	can_damage = true
	
func move_debug_line():
	debug_line.clear_points()
	debug_line.global_position = global_position
	debug_line.add_point(Vector2.ZERO, 0)
	debug_line.add_point(target_position, 1)
