class_name Hub extends Node2D

var shop: Shop
var mission_board: MissionBoard

func _ready() -> void:
	shop = $Shop
	mission_board = $MissionBoard
