class_name Shop extends Area2D

@export var hub: Hub

func _ready() -> void:
	$Interactable.did_interact.connect(_on_interact)

func _on_interact() -> void:
	hub.open_shop_screen()
