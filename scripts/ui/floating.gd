extends Control

@export var speed: float = 1.0
@export var amplitude_factor: float = 5.0

@onready var _time := randf_range(0, PI)
@onready var _original_y := position.y

func _process(delta: float) -> void:
	position.y = _original_y + sin(_time * speed) * amplitude_factor
	# Prevent time from getting too large
	_time = fmod(_time + delta, TAU)
