extends Control

@export var speed: float = 1.0
@export var amplitude_factor: float = 0.2

var _time: float

func _ready() -> void:
	_time = randf_range(0, PI)

func _process(delta: float) -> void:
	position.y += sin(_time * speed) * amplitude_factor
	_time = fmod(_time + delta, TAU)
