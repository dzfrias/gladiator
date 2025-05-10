class_name Drone extends Node2D

@export var active_time = 5
var move_dist = Vector2(0, 15)
var tween_duration = 1
var y_move_dir = 1

func init(direction: Direction):
	pass

func _ready() -> void:
	_hover()
	await get_tree().create_timer(active_time).timeout
	queue_free()

func _process(delta: float) -> void:
	var closest_target = find_closest_target()
	if closest_target and $Weapon.can_fire:
		var angle = global_position.angle_to_point(closest_target.global_position)
		$Weapon.fire(angle)

func _hover():
	while true:
		var tween := get_tree().create_tween()
		tween.tween_property(self, "global_position", global_position + move_dist * y_move_dir, tween_duration)
		tween.set_ease(Tween.EaseType.EASE_IN)
		await tween.finished
		y_move_dir *= -1

func find_closest_target():
	var closest_dist = INF
	var closest_enemy = null
	for body in $DetectionZone.get_overlapping_bodies():
		var dist = global_position.distance_to(body.global_position)
		if dist < closest_dist:
			closest_enemy = body
			closest_dist = dist
	return closest_enemy
