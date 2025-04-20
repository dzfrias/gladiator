class_name Module extends Node2D

@export var delta_y: int
@export var decoration_chance: float = 0.6

var tile_size: Vector2

var left_boundary: float
var right_boundary: float

var _decorations: Array[PackedScene] = [
	preload("res://scenes/decoration/rock.tscn"),
	preload("res://scenes/decoration/dead_tree.tscn"),
	preload("res://scenes/decoration/grass.tscn"),
]

func _ready() -> void:
	assert(tile_size.length() > 0)
	$Tiles.queue_free()
	
	var width = $Tiles.get_used_rect().size.x
	left_boundary = 0.0
	right_boundary = width * tile_size.x
	
	if has_node("Decorations"):
		for decoration_spot in $Decorations.get_children():
			if randf() > decoration_chance:
				continue
			var decoration := _decorations[randi_range(0, _decorations.size() - 1)].instantiate() as Node2D
			decoration.position = decoration_spot.position
			add_child(decoration)

func tiles() -> TileMapLayer:
	return $Tiles
