extends Node

var weather: Node
var mission: Mission

var _mission_scene = preload("res://scenes/mission.tscn")
var _home_scene = preload("res://scenes/test_scene.tscn")

func enter_mission() -> void:
	_goto_mission.call_deferred()

func return_home() -> void:
	assert(mission != null)
	_goto_home.call_deferred()

func _goto_home() -> void:
	_load_scene(_home_scene)

func _goto_mission() -> void:
	var new_scene := _load_scene(_mission_scene)
	if weather:
		new_scene.add_child(weather)
	new_scene.add_child(mission)
	mission.mission_finished.connect(return_home)

func _load_scene(scene: PackedScene) -> Node:
	get_tree().root.get_child(-1).free()
	var new_scene = scene.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	return new_scene
