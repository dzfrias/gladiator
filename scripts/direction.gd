class_name Direction extends Node

var is_right: bool = true
var scalar: float:
	get:
		if is_right:
			return 1.0
		else:
			return -1.0
	set(new):
		assert(absf(new) == 1)
		if new == 1.0:
			is_right = true
		else:
			is_right = false
