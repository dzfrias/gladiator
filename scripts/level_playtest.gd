extends Node2D

func _ready() -> void:
	var pistol = preload("res://resources/pistol.tres")
	$Player.inventory().add_item(pistol)
