class_name Shop extends Area2D

func _ready() -> void:
	$Interactable.did_interact.connect(_on_interact)

func _on_interact() -> void:
	Hub.open_shop_screen()
