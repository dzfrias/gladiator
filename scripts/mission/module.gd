class_name Module extends Node2D

@export var delta_y: int

var tile_size: Vector2

var left_boundary: float
var right_boundary: float

func _ready() -> void:
	assert(tile_size.length() > 0)
	$Tiles.queue_free()
	
	var width = $Tiles.get_used_rect().size.x
	left_boundary = 0.0
	right_boundary = width * tile_size.x

func tiles() -> TileMapLayer:
	return $Tiles
