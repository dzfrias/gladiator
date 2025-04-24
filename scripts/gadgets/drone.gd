class_name Drone extends Node2D

@export var active_time = 5

func init(direction: Direction):
	pass

func _ready() -> void:
	await get_tree().create_timer(active_time).timeout
	queue_free()

func _process(delta: float) -> void:
	var closest_target = find_closest_target()
	if closest_target and $Weapon.can_fire:
		var angle = global_position.angle_to_point(closest_target.global_position)
		$Weapon.fire(angle)

func find_closest_target():
	var closest_dist = INF
	var closest_enemy = null
	for body in $DetectionZone.get_overlapping_bodies():
		var dist = global_position.distance_to(body.global_position)
		if dist < closest_dist:
			closest_enemy = body
			closest_dist = dist
	return closest_enemy
