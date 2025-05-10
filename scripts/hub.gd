class_name Hub extends Node2D

@export var reset_save: bool = true

var shop: Shop
var mission_board: MissionBoard

var _win_screen: PackedScene = preload("res://scenes/win_screen.tscn")

func _ready() -> void:
	shop = $Shop
	mission_board = $MissionBoard
	if reset_save:
		PersistentData.reset()
		PersistentData.done_tutorial = false
	_play_sound.call_deferred()
	$Player.set_alt_weapon(PersistentData.alternate)
	$Player.gadget().set_gadget(PersistentData.gadget)
	for passive in PersistentData.get_passives():
		$Player.add_passive(passive)
	
	if PersistentData.level == 6:
		_win.call_deferred()

func _win() -> void:
	get_tree().change_scene_to_packed(_win_screen)

func _play_sound():
	AudioManager.play_music(preload("res://assets/Music/hub_music.wav"), 5)
