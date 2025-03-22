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

var _terrain := [
	WeightedScene.new("res://scenes/modules/terrain/flat.tscn", 0.5),
	WeightedScene.new("res://scenes/modules/terrain/slope_up.tscn", 0.25),
	WeightedScene.new("res://scenes/modules/terrain/slope_down.tscn", 0.25),
]
var _encounters := [
	WeightedScene.new("res://scenes/modules/encounters/basic.tscn", 0.05),
	WeightedScene.new("res://scenes/modules/encounters/encounter1.tscn", 0.15),
	WeightedScene.new("res://scenes/modules/encounters/encounter2.tscn", 0.15),
	WeightedScene.new("res://scenes/modules/encounters/encounter3.tscn", 0.15),
	WeightedScene.new("res://scenes/modules/encounters/housing_encounter.tscn", 0.175),
	WeightedScene.new("res://scenes/modules/encounters/outpost_encounter.tscn", 0.15),
	WeightedScene.new("res://scenes/modules/encounters/campsite_encounter.tscn", 0.175),
]
var _start_module: PackedScene = preload("res://scenes/modules/terrain/flat.tscn")
var _fill_tiles: Array[FillTile] = []
var _fill_source_id: int
var _tile_size: Vector2

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
	
	_generate.call_deferred()

func _generate() -> void:
	var module_origin := Vector2i(0, 0)
	module_origin += _place_module(module_origin, _start_module)

	var next_encounter := randi_range(3, 4)
	while module_origin.x < map_width:
		var module: WeightedScene
		if next_encounter == 0:
			module = weighted_choice(_encounters)
			next_encounter = randi_range(3, 4)
		else:
			module = weighted_choice(_terrain)
			next_encounter -= 1
		var delta := _place_module(module_origin, module.scene)
		module_origin += delta

func _place_module(origin: Vector2i, module: PackedScene) -> Vector2i:
	var instance = module.instantiate() as Module
	var scene_origin := to_global(map_to_local(origin)) - _tile_size / 2
	instance.global_position = scene_origin
	instance.tile_size = _tile_size
	
	var lowest_y := -100000
	for tile in instance.tiles().get_used_cells():
		var source_id = instance.tiles().get_cell_source_id(tile)
		var atlas_coords = instance.tiles().get_cell_atlas_coords(tile)
		var coords = origin + tile
		set_cell(coords, source_id, atlas_coords)
		lowest_y = maxi(coords.y, lowest_y)
	
	var width = instance.tiles().get_used_rect().size.x
	_fill(Vector2i(origin.x, lowest_y + 1), width)
	
	add_child(instance as Object)
	
	return Vector2i(width, instance.delta_y)

func _fill(origin: Vector2i, width: int) -> void:
	const Y_HEIGHT = 1000
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
		if cumulative <= rand:
			continue
		return item
	
	# Should be unreachable
	assert(false)
	return null
