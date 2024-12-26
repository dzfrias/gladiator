extends Node2D

@export var procedural_generation: ProceduralGeneration
@export var structure_scene: PackedScene

@onready var fnl = FastNoiseLite.new()
@onready var flat_ground_required = get_structure_size()[0]
var taken_locations: Array
var tile_offset = Vector2(-64, 64)

func _ready() -> void:
	fnl.seed = randi_range(0, 1000)
	for x in range(0, procedural_generation.get_x_distance()):
		if is_flat_ground(x) and !taken_locations.has(x) and fnl.get_noise_1d(x) > 0:
			spawn_structure(x)

func is_flat_ground(x):
	var ground_height = procedural_generation.get_ground_height(x)
	if x + flat_ground_required > procedural_generation.get_x_distance(): return false # Checks if the map ends
	for i in range(x, x + flat_ground_required):
		var current_ground_height = procedural_generation.get_ground_height(i)
		if current_ground_height != ground_height:
			return false
	return true

func add_taken_location(start, end):
	for i in range(start, end):
		taken_locations.append(i)

func spawn_structure(x):
	print("spawned structure")
	var structure = structure_scene.instantiate()
	add_taken_location(x, x + flat_ground_required)
	var tilemap_to_global = procedural_generation.to_global(procedural_generation.map_to_local(Vector2(x, procedural_generation.get_ground_height(x) - 1)))
	structure.global_position = tilemap_to_global + tile_offset
	get_tree().root.add_child.call_deferred(structure)
	copy(structure)

func copy(structure_tilemap: TileMapLayer):
	for cell in structure_tilemap.get_used_cells():
		var global_cell_pos = structure_tilemap.to_global(structure_tilemap.map_to_local(cell))
		var new_cell_pos = procedural_generation.local_to_map(procedural_generation.to_local(global_cell_pos))
		procedural_generation.set_cell(new_cell_pos, 1, Vector2(0, 0))
	structure_tilemap.queue_free()

func get_structure_size():
	var structure = structure_scene.instantiate() as TileMapLayer
	return structure.get_used_rect().size
	structure.queue_free()
