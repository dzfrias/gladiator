class_name Direction extends Node

var is_right: bool = true
var scalar: float:
	get:
		return 1.0 if is_right else -1.0
	set(new):
		assert(absf(new) == 1)
		is_right = new == 1.0
var angle: float:
	get:
		return 0.0 if is_right else PI

func switch() -> void:
	is_right = !is_right
