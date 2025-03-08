extends Node2D

var _shop_scene = preload("res://scenes/shop_screen.tscn")
var _world_scene = preload("res://scenes/hub.tscn")
var _world: Node

func open_shop_screen() -> void:
	_world = get_tree().current_scene
	get_tree().root.remove_child(_world)
	var new_scene = _shop_scene.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func return_to_world() -> void:
	get_tree().current_scene.queue_free()
	_setup_world.call_deferred()

func _setup_world() -> void:
	get_tree().root.add_child(_world)
	get_tree().current_scene = _world
