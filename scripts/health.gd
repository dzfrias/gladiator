class_name Health

extends Node

signal damage_taken(amount: float)
signal health_gained(amount: float)
signal died

@export var max_health: float = 20
var health: float:
	get: return _health
var _health: float

func _ready() -> void:
	_health = max_health

func take_damage(amount: float) -> void:
	_health = max(_health - amount, 0)
	if _health == 0:
		died.emit()
		return
	damage_taken.emit(amount)

func heal(amount: float) -> void:
	_health = min(_health + amount, max_health)
	health_gained.emit(amount)
