extends Node

var mission: Mission

var _mission_scene = preload("res://scenes/mission.tscn")

func enter_mission(m: Mission) -> void:
	mission = m
	_goto_mission.call_deferred()

func return_home(success: bool) -> void:
	_goto_home.call_deferred(success)

func _goto_home(success: bool) -> void:
	if not success:
		PersistentData.reset()
	else:
		PersistentData.buckles += mission.buckles
	HubManager.go_to_hub()

func _goto_mission() -> void:
	var new_scene := _load_scene(_mission_scene)
	new_scene.add_child(mission)
	var player := new_scene.find_child("Player") as Player
	player.gadget().set_gadget(PersistentData.gadget)
	player.set_alt_weapon(PersistentData.alternate)
	for passive in PersistentData.get_passives():
		player.add_passive(passive)
	mission.mission_finished.connect(return_home)

func _load_scene(scene: PackedScene) -> Node:
	get_tree().root.get_child(-1).free()
	var new_scene = scene.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	return new_scene
