extends Node

@export var amount: float = 5.0

func _enter_tree() -> void:
	await get_tree().process_frame
	Player.Instance.get_health().max_health += amount
	Player.Instance.get_health().heal(amount)

func _exit_tree() -> void:
	Player.Instance.get_health().max_health -= amount
