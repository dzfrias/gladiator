extends Sprite2D

@export var vertical: bool = false
@export var restrict: Array[int] = []
@export var scale_factor_min: float = 0.5
@export var scale_factor_max: float = 1.5
@export var y_offset_max: float = 0.0

static var last_used: Dictionary

func _ready() -> void:
	assert(region_enabled)
	
	var region_size := Vector2i(region_rect.size)
	var i: int = 0 if not vertical else 1
	
	assert(int(texture.get_size()[i]) % region_size[i] == 0)
	
	var p: int = -1
	while p == -1 or p == last_used.get(texture.resource_path):
		if restrict.is_empty():
			p = randi_range(0, int(texture.get_size()[i] / region_size[i]) - 1)
		else:
			p = restrict[randi_range(0, restrict.size() - 1)]
	assert(p != -1)
	last_used[texture.resource_path] = p
	
	var scale_factor := randf_range(scale_factor_min, scale_factor_max)
	var height := region_rect.size.y * scale.y
	scale *= scale_factor
	position.y -= ((scale_factor - 1) * height) / 2
	
	position.y += randf_range(0.0, y_offset_max) * scale_factor
	
	region_rect = Rect2(0, 0, region_size.x, region_size.y)
	region_rect.position[i] = p * region_size[i]
	
	flip_h = randf() < 0.5
