class_name Interactable extends Area2D

signal did_interact

func interact() -> void:
	did_interact.emit()
