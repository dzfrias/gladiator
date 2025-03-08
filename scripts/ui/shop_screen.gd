class_name ShopScreen extends Node2D

signal quit

func _ready() -> void:
	$CanvasLayer/Return.pressed.connect(_on_quit_pressed)

func _on_quit_pressed() -> void:
	quit.emit()
