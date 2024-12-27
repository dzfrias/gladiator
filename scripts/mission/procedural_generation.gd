class_name ProceduralGeneration extends TileMapLayer

const BLOCK_ID = 1
const BLOCK_TILE_ATLAS_POS = Vector2(0, 0)

@export var x_distance = 200

var depth_multiplier = 20
var y_distance = 50
@onready var _noise: FastNoiseLite = FastNoiseLite.new()

var _ground_heights: Array[int]

func _ready() -> void:
	_noise.seed = randi_range(0, 1000)
	for x in x_distance:
		var ground := absi(_noise.get_noise_2d(x, 0) * depth_multiplier)
		_ground_heights.append(ground)
		for y in range(ground, y_distance):
			set_cell(Vector2(x, y), BLOCK_ID, BLOCK_TILE_ATLAS_POS)

func get_ground_height(x_pos: int) -> int:
	return _ground_heights[x_pos]
