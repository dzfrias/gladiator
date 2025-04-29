extends Node

@export var boost: float = 700.0

func _ready() -> void:
	await get_tree().process_frame
	Player.Instance.movement_settings.burrow_speed_boost = boost
