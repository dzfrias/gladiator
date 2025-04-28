class_name Hub extends Node2D

@export var reset_save: bool = true

var shop: Shop
var mission_board: MissionBoard

func _ready() -> void:
	shop = $Shop
	mission_board = $MissionBoard
	if reset_save:
		PersistentData.reset()
	$Player.set_alt_weapon(PersistentData.alternate)
	$Player.gadget().set_gadget(PersistentData.gadget)
	for passive in PersistentData.get_passives():
		$Player.add_passive(passive)
