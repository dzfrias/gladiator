extends TileMapLayer

const BLOCK_ID = 1
const BLOCK_TILE_ATLAS_POS = Vector2(0, 0)

@export var noise_sprite: Sprite2D

@onready var noise: Noise = noise_sprite.texture.noise
var depth_multiplier = 20
var x_distance = 200
var y_distance = 10

func _ready() -> void:
	noise.seed = randi_range(0, 1000)
	for x in x_distance:
		var ground = abs(noise.get_noise_2d(x, 0) * depth_multiplier)
		for y in range(ground, y_distance):
			set_cell(Vector2(x, y), BLOCK_ID, BLOCK_TILE_ATLAS_POS)
