class_name Mission extends Node

var gold: int

signal mission_finished

func _enter_tree() -> void:
	assert(gold > 0)
