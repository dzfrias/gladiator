class_name SpeedBoost extends Node

var active_time = 3
var speed_multiplier = 1.3

func init(direction: Direction):
	pass

func _ready() -> void:
	var original_speed = Player.Instance.movement_settings.move_speed
	Player.Instance.movement_settings.move_speed *= speed_multiplier
	await get_tree().create_timer(active_time).timeout
	Player.Instance.movement_settings.move_speed = original_speed
	queue_free()
