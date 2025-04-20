extends Sprite2D

@export var vertical: bool = false
@export var restrict: Array[int] = []

func _ready() -> void:
	assert(region_enabled)
	
	var region_size := Vector2i(region_rect.size)
	var i: int = 0 if not vertical else 1
	
	assert(int(texture.get_size()[i]) % region_size[i] == 0)
	
	var p: int
	if restrict.is_empty():
		p = randi_range(0, int(texture.get_size()[i] / region_size[i]) - 1)
	else:
		p = restrict[randi_range(0, restrict.size() - 1)]
	
	region_rect = Rect2(0, 0, region_size.x, region_size.y)
	region_rect.position[i] = p * region_size[i]
	
	flip_h = randf() < 0.5
