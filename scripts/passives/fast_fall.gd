extends Node

func _ready() -> void:
	await get_tree().process_frame
	Player.Instance.movement_settings.fast_fall_gravity_scale = 10.0
