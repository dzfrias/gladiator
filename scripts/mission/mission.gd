class_name Mission extends Node

var buckles: int
var weather: Node
var in_combat: bool:
	get:
		return _in_combat
	set(new):
		var old := _in_combat
		_in_combat = new
		if old != new and new:
			entered_combat.emit()
		if old != new and not new:
			exited_combat.emit()

var _in_combat: bool = false

@warning_ignore("unused_signal")
signal mission_finished
signal entered_combat
signal exited_combat

func _ready() -> void:
	assert(buckles > 0)
	_setup.call_deferred()

func _setup() -> void:
	if weather:
		get_tree().current_scene.add_child(weather)
