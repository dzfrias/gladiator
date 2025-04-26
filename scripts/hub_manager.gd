extends Node2D

var world: Hub

var _shop_scene = preload("res://scenes/shop_screen.tscn")
var _mission_scene = preload("res://scenes/mission_board_screen.tscn")
var _world_scene = preload("res://scenes/hub.tscn")

func _ready() -> void:
	world = _world_scene.instantiate()

func open_shop_screen() -> void:
	var new_scene = _shop_scene.instantiate()
	_load(new_scene)

func open_mission_select_screen() -> void:
	var scene = _mission_scene.instantiate()
	_load(scene)

func enter_mission(mission: Mission) -> void:
	MissionManager.enter_mission(mission)
	world.queue_free()

func go_to_hub() -> void:
	
	world = _world_scene.instantiate()
	var new_player := world.find_child("Player") as Player

	new_player.set_alt_weapon(PersistentData.alternate)
	new_player.gadget().set_gadget(PersistentData.gadget)
	
	get_tree().current_scene.free()
	_setup_world.call_deferred()

func return_to_world() -> void:
	get_tree().current_scene.queue_free()
	_setup_world.call_deferred()

func _setup_world() -> void:
	get_tree().root.add_child(world)
	get_tree().current_scene = world

func _load(to: Node) -> void:
	if get_tree().current_scene != world:
		world = get_tree().current_scene
	get_tree().root.remove_child(world)
	get_tree().root.add_child(to)
	get_tree().current_scene = to
