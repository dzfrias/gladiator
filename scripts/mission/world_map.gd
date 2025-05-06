class_name WorldMap extends TileMapLayer

class WeightedScene:
	var scene: PackedScene
	var weight: float
	
	func _init(scene_path: String, module_weight: float):
		assert(module_weight <= 1.0 and module_weight >= 0.0)
		scene = load(scene_path)
		weight = module_weight

class FillTile:
	var atlas_coords: Vector2i
	var weight: float
	
	func _init(coords: Vector2i, tile_weight: float):
		assert(tile_weight <= 1.0 and tile_weight >= 0.0)
		atlas_coords = coords
		weight = tile_weight

@export var map_width: int = 200
@export var y_max: int = 10
@export var starting_chest_spawn_chance: float = 0.2
@export var chest_spawn_chance_increment: float = 0.2
@export var encounter_dist_min: int = 50
@export var encounter_dist_max: int = 80
@export_dir var terrain_path: String = "res://scenes/modules/terrain/"

var _encounters := [
	WeightedScene.new("res://scenes/modules/encounters/silo_encounter.tscn", 0.0),
	WeightedScene.new("res://scenes/modules/encounters/tire_fort_encounter.tscn", 0.0),
	WeightedScene.new("res://scenes/modules/encounters/containers_encounter.tscn", 0.0),
	WeightedScene.new("res://scenes/modules/encounters/outpost_encounter.tscn", 1.0),
	#WeightedScene.new("res://scenes/modules/encounters/encounter2.tscn", 0.15),
	#WeightedScene.new("res://scenes/modules/encounters/encounter3.tscn", 0.15),
	#WeightedScene.new("res://scenes/modules/encounters/housing_encounter.tscn", 0.175),
	#WeightedScene.new("res://scenes/modules/encounters/outpost_encounter.tscn", 0.15),
	#WeightedScene.new("res://scenes/modules/encounters/campsite_encounter.tscn", 0.175),
]
var _start_module: PackedScene = preload("res://scenes/modules/terrain/flat.tscn")
var _fill_tiles: Array[FillTile] = []
var _fill_source_id: int
var _tile_size: Vector2
var _terrain: Array[PackedScene]

func _ready() -> void:
	assert(scale.x == scale.y)
	_tile_size = tile_set.tile_size * scale.x
	_fill_source_id = tile_set.get_source_id(0)
	var source := tile_set.get_source(_fill_source_id) as TileSetAtlasSource
	for i in source.get_tiles_count():
		var tile_coords := source.get_tile_id(i)
		var data := source.get_tile_data(tile_coords, 0)
		var fill_probability := data.get_custom_data("fill") as float
		assert(fill_probability >= 0.0)
		if fill_probability > 0.0:
			_fill_tiles.append(FillTile.new(tile_coords, fill_probability))
	
	_terrain = scenes_in_dir(terrain_path)
	
	_generate.call_deferred()

func _generate() -> void:
	var module_origin := Vector2i(0, 0)
	module_origin += _place_module(module_origin, _start_module.instantiate())

	var encounter_dist := randi_range(encounter_dist_min, encounter_dist_max)
	var chest_spawn_chance := starting_chest_spawn_chance
	while module_origin.x < map_width:
		var module: PackedScene
		if encounter_dist == 0:
			module = weighted_choice(_encounters).scene
			encounter_dist = randi_range(encounter_dist_min, encounter_dist_max)
		else:
			module = _terrain[randi_range(0, _terrain.size() - 1)]
		
		var instance := module.instantiate() as Module
		
		if instance is CombatEncounter:
			if randf() <= chest_spawn_chance:
				instance.will_spawn_chest = true
				chest_spawn_chance = starting_chest_spawn_chance
			else:
				instance.will_spawn_chest = false
				chest_spawn_chance = minf(chest_spawn_chance + chest_spawn_chance_increment, 1.0)
		
		if module_origin.y + instance.delta_y < -y_max or module_origin.y + instance.delta_y > 0:
			continue
		
		if instance is not CombatEncounter:
			encounter_dist = maxi(encounter_dist - instance.tiles().get_used_rect().size.x, 0)
		
		var delta := _place_module(module_origin, instance)
		module_origin += delta

func _place_module(origin: Vector2i, instance: Module) -> Vector2i:
	var scene_origin := to_global(map_to_local(origin)) - _tile_size / 2
	instance.global_position = scene_origin
	instance.tile_size = _tile_size
	
	var lowest_y := -100000
	for tile in instance.tiles().get_used_cells():
		var source_id = instance.tiles().get_cell_source_id(tile)
		var atlas_coords = instance.tiles().get_cell_atlas_coords(tile)
		var alternative_tile = instance.tiles().get_cell_alternative_tile(tile)
		var coords = origin + tile
		set_cell(coords, source_id, atlas_coords, alternative_tile)
		lowest_y = maxi(coords.y, lowest_y)
	
	var width = instance.tiles().get_used_rect().size.x
	_fill(Vector2i(origin.x, lowest_y + 1), width)
	
	add_child(instance)
	
	return Vector2i(width, instance.delta_y)

func _fill(origin: Vector2i, width: int) -> void:
	const Y_HEIGHT = 20
	for i in range(width):
		for j in range(Y_HEIGHT):
			var fill_tile = weighted_choice(_fill_tiles)
			set_cell(
				origin + i * Vector2i.RIGHT + j * Vector2i.DOWN,
				_fill_source_id,
				fill_tile.atlas_coords
			)

static func weighted_choice(array: Array) -> Variant:
	var rand := randf()
	var cumulative := 0.0
	for item in array:
		cumulative += item.weight
		assert(cumulative <= 1.0)
		if cumulative < rand:
			continue
		return item
	
	# Should be unreachable
	assert(false)
	return null

static func scenes_in_dir(path: String):
	var scenes: Array[PackedScene] = []
	
	var dir := DirAccess.open(path)
	if not dir:
		printerr("An error occurred when trying to access %s" % path)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.get_extension() == "tscn":
			var full_path = path.path_join(file_name)
			scenes.append(load(full_path))
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return scenes
