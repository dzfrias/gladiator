class_name WorldMap extends TileMapLayer

class ModuleInfo:
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

@export var map_width: int = 100

var _terrain := [
	ModuleInfo.new("res://scenes/modules/terrain/flat.tscn", 0.5),
	ModuleInfo.new("res://scenes/modules/terrain/slope_up.tscn", 0.5),
]
var _fill_tiles: Array[FillTile] = []
var _fill_source_id: int

func _ready() -> void:
	_fill_source_id = tile_set.get_source_id(0)
	var source := tile_set.get_source(_fill_source_id) as TileSetAtlasSource
	for i in source.get_tiles_count():
		var tile_coords := source.get_tile_id(i)
		var data := source.get_tile_data(tile_coords, 0)
		var fill_probability := data.get_custom_data("fill") as float
		assert(fill_probability >= 0.0)
		if fill_probability > 0.0:
			_fill_tiles.append(FillTile.new(tile_coords, fill_probability))
	
	_generate()

func _generate() -> void:
	var module_origin := Vector2i(0, 0)
	while module_origin.x < map_width:
		var module = weighted_choice(_terrain)
		var delta := _place_module(module_origin, module)
		module_origin += delta

func _place_module(origin: Vector2i, module: ModuleInfo) -> Vector2i:
	var instance = module.scene.instantiate() as Module
	instance.queue_free()
	
	var lowest_y := -100000
	for tile in instance.get_used_cells():
		var source_id := instance.get_cell_source_id(tile)
		var atlas_coords := instance.get_cell_atlas_coords(tile)
		var coords := origin + tile
		set_cell(coords, source_id, atlas_coords)
		lowest_y = maxi(coords.y, lowest_y)
	
	var width := instance.get_used_rect().size.x
	_fill(Vector2i(origin.x, lowest_y + 1), width)
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
