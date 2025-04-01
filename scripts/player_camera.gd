class_name PlayerCamera extends Camera2D

@export var decay: float = 0.8
@export var max_offset := Vector2(100,75)
@export var max_roll: float = 0.0
@export var noise: FastNoiseLite

@onready var _original_offset = offset
var noise_y := 0.0
var trauma := 0.0
var trauma_pwr := 3.0

func _ready():
	randomize()
	noise.seed = randi()

func add_trauma(amount: float):
	assert(amount > 0.0 and amount <= 1.0)
	trauma = min(trauma + amount, 1.0)

func move(by: Vector2) -> void:
	offset += by

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		_shake()
	elif offset != _original_offset or rotation != 0:
		offset = offset.lerp(_original_offset, delta * 10)
		lerp(rotation, 0.0, 1)

func _shake(): 
	var amt := pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(0, noise_y)
	offset.x = _original_offset.x + max_offset.x * amt * noise.get_noise_2d(1000, noise_y)
	offset.y = _original_offset.y + max_offset.y * amt * noise.get_noise_2d(2000, noise_y)
