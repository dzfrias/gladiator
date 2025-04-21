class_name EdgeDetector extends Node2D

var left: RayCast2D
var right: RayCast2D

func _ready() -> void:
	left = _create_ray(true)
	add_child(left)
	right = _create_ray(false)
	add_child(right)

func _create_ray(is_left: bool) -> RayCast2D:
	var bounding_box: Rect2 = $"../CollisionShape2D".shape.get_rect()
	var ray := RayCast2D.new()
	ray.collision_mask = Constants.PLATFORM_LAYER | Constants.ENVIRONMENT_LAYER
	ray.target_position = Vector2(0.0, bounding_box.size.y / 2)
	ray.position.x = bounding_box.size.x / 2 + 10
	if is_left:
		ray.position.x *= -1
	ray.position.y += bounding_box.size.y / 2 - 10
	return ray
