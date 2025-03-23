class_name Mission extends Node

var buckles: int
var weather: Node

@warning_ignore("unused_signal")
signal mission_finished

func _ready() -> void:
	assert(buckles > 0)
	_setup.call_deferred()

func _setup() -> void:
	get_tree().current_scene.add_child(weather)
