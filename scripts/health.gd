class_name Health extends Node

signal damage_taken(amount: float, direction: Vector2)
signal health_gained(amount: float)
signal max_health_changed
signal died

@export var max_health: float = 20:
	set(new_max):
		_health = new_max
		max_health = new_max
		max_health_changed.emit()
var health: float:
	get: return _health
var has_died: bool:
	get: return _died
var _health: float
var _died := false

func _ready() -> void:
	_health = max_health

func take_damage(amount: float, direction: Vector2) -> void:
	if _died: return
	var old := _health
	_health = max(_health - amount, 0)
	damage_taken.emit(old - _health, direction)
	if _health == 0:
		died.emit()
		_died = true
		return

func restore() -> void:
	_health = max_health
	_died = false

func heal(amount: float) -> void:
	if _died: return
	_health = min(_health + amount, max_health)
	health_gained.emit(amount)
