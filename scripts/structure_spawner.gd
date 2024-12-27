extends Node2D

@export var procedural_generation: ProceduralGeneration
@export var structure_scene: PackedScene

@onready var fnl = FastNoiseLite.new()
@onready var flat_ground_required = _get_structure_size()[0]
var _taken_locations: Array[int]

var tile_offset = Vector2(-64, 64)

func _ready() -> void:
	fnl.seed = randi_range(0, 1000)
	for x in range(0, procedural_generation.x_distance):
		if _is_flat_ground(x) and !_taken_locations.has(x) and fnl.get_noise_1d(x) > 0:
			_spawn_structure(x)

func _is_flat_ground(x: int) -> bool:
	var ground_height = procedural_generation.get_ground_height(x)
	if x + flat_ground_required > procedural_generation.x_distance:
		return false # Checks if the map ends
	for i in range(x, x + flat_ground_required):
		var current_ground_height = procedural_generation.get_ground_height(i)
		if current_ground_height != ground_height:
			return false
	return true

func _add_taken_location(start: int, end: int) -> void:
	for i in range(start, end):
		_taken_locations.append(i)

func _spawn_structure(x: int) -> void:
	print("spawned structure")
	var structure = structure_scene.instantiate()
	_add_taken_location(x, x + flat_ground_required)
	var tilemap_to_global = procedural_generation.to_global(procedural_generation.map_to_local(Vector2(x, procedural_generation.get_ground_height(x) - 1)))
	structure.global_position = tilemap_to_global + tile_offset
	_copy(structure)
	structure.queue_free()

func _copy(structure_tilemap: TileMapLayer) -> void:
	for cell in structure_tilemap.get_used_cells():
		var global_cell_pos = structure_tilemap.to_global(structure_tilemap.map_to_local(cell))
		var new_cell_pos = procedural_generation.local_to_map(procedural_generation.to_local(global_cell_pos))
		procedural_generation.set_cell(new_cell_pos, 1, Vector2i(0, 0))

func _get_structure_size() -> Vector2i:
	var structure = structure_scene.instantiate() as TileMapLayer
	structure.queue_free()
	return structure.get_used_rect().size
