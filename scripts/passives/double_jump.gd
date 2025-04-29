extends Node

func _ready() -> void:
	await get_tree().process_frame
	Player.Instance.movement_settings.njumps = 2
