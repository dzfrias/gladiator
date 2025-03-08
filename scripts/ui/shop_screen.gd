class_name ShopScreen extends Node2D

func _ready() -> void:
	$CanvasLayer/Return.pressed.connect(_on_quit_pressed)

func _on_quit_pressed() -> void:
	Hub.return_to_world()
