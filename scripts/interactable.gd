class_name Interactable extends Node

signal did_interact

func interact() -> void:
	did_interact.emit()
