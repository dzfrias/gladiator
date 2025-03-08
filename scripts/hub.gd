class_name Hub extends Node2D

var _shop_scene = preload("res://scenes/shop_screen.tscn")

func open_shop_screen() -> void:
	$World.process_mode = Node.PROCESS_MODE_DISABLED
	var shop := _shop_scene.instantiate() as ShopScreen
	shop.quit.connect(_return_to_world)
	add_child(shop)

func _return_to_world() -> void:
	get_child(-1).queue_free()
	$World.process_mode = Node.PROCESS_MODE_INHERIT
