extends Node

@export var factor: float = 1.5

func _enter_tree() -> void:
	await get_tree().process_frame
	Player.Instance.movement_settings.move_speed *= factor
	Player.Instance.movement_settings.burrow_speed *= factor

func _exit_tree() -> void:
	Player.Instance.movement_settings.move_speed /= factor
	Player.Instance.movement_settings.burrow_speed /= factor
