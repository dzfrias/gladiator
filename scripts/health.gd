class_name Health extends Node

signal damage_taken(amount: float, direction: Vector2)
signal health_gained(amount: float)
signal died

@export var max_health: float = 20
@export var invincible_time: float = 0.0
var health: float:
	get: return _health
var has_died: bool:
	get: return _died
var is_invincible: bool
var _health: float
var _died := false

func _ready() -> void:
	_health = max_health

func take_damage(amount: float, direction: Vector2) -> void:
	if _died or is_invincible: return
	var old := _health
	_health = max(_health - amount, 0)
	_invincible()
	damage_taken.emit(old - _health, direction)
	if _health == 0:
		died.emit()
		_died = true
		return

func heal(amount: float) -> void:
	if _died: return
	_health = min(_health + amount, max_health)
	health_gained.emit(amount)

func _invincible() -> void:
	if invincible_time == 0: return
	is_invincible = true
	await get_tree().create_timer(invincible_time).timeout
	is_invincible = false
