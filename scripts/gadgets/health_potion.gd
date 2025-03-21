class_name HealthPotion extends Node

var health_increase_amount = 5

func init(direction: Direction):
	pass

func _ready() -> void:
	Player.Instance.get_health().heal(health_increase_amount)
	queue_free()
