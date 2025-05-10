class_name Mission extends Node

var buckles: int
var weather: Node
var difficulty: Difficulty = Difficulty.MEDIUM
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
var scene: PackedScene = load("res://scenes/mission.tscn")

enum Difficulty {
	EASY,
	MEDIUM,
	HARD
}

var _in_combat: bool = false
var _effects_scene = preload("res://scenes/load_effects.tscn")
var _death_ui = preload("res://scenes/died.tscn")

signal mission_finished(success: bool)
signal entered_combat
signal exited_combat

func _ready() -> void:
	assert(buckles >= 0)
	_setup.call_deferred()
	
	match difficulty:
		Difficulty.EASY:
			Player.Instance.get_health().max_health += 10
		Difficulty.MEDIUM:
			Player.Instance.get_health().max_health += 5
	mission_finished.connect(_take_health)

func _take_health(_success: bool) -> void:
	match difficulty:
		Difficulty.EASY:
			Player.Instance.get_health().max_health -= 10
		Difficulty.MEDIUM:
			Player.Instance.get_health().max_health -= 5

func _setup() -> void:
	if weather:
		get_tree().current_scene.add_child(weather)
	
	Player.Instance.get_health().died.connect(_on_player_died)

func _on_player_died() -> void:
	var effects := _effects_scene.instantiate() as LoadEffects
	get_tree().current_scene.add_child(effects)
	await effects.load_in()
	var ui = _death_ui.instantiate()
	get_tree().current_scene.add_child(ui)
	ui.find_child("ReturnButton").pressed.connect(func(): mission_finished.emit(false))

func _defeat():
	mission_finished.emit(false)
