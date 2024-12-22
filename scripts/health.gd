class_name Health extends Node

signal damage_taken(amount: float)
signal health_gained(amount: float)
signal died

@export var max_health: float = 20
var health: float:
	get: return _health
var has_died: bool:
	get: return _died
var _health: float
var _died := false

func _ready() -> void:
	_health = max_health

func take_damage(amount: float) -> void:
	if _died: return
	_health = max(_health - amount, 0)
	if _health == 0:
		died.emit()
		_died = true
		return
	damage_taken.emit(amount)

func heal(amount: float) -> void:
	if _died: return
	_health = min(_health + amount, max_health)
	health_gained.emit(amount)
