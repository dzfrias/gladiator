extends Node

var mission: Mission

var _mission_scene = preload("res://scenes/mission.tscn")

func enter_mission(m: Mission) -> void:
	mission = m
	_goto_mission.call_deferred()

func return_home() -> void:
	_goto_home.call_deferred()

func _goto_home() -> void:
	HubManager.go_to_hub()
	HubManager.world.shop.buckles += mission.buckles

func _goto_mission() -> void:
	var items = []
	for item in Player.Instance.inventory().items:
		items.append(item)
	var alt_weapon = Player.Instance.alt_weapon
	var new_scene := _load_scene(_mission_scene)
	new_scene.add_child(mission)
	var player := new_scene.find_child("Player") as Player
	for item in items:
		player.inventory().add_item(item)
	player.alt_weapon = alt_weapon
	mission.mission_finished.connect(return_home)

func _load_scene(scene: PackedScene) -> Node:
	get_tree().root.get_child(-1).free()
	var new_scene = scene.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	return new_scene
