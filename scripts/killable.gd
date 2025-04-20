class_name Killable extends Node2D

func _ready() -> void:
	$Health.died.connect(_on_died)

func _on_died() -> void:
	queue_free()
