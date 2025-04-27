class_name AOEDamage extends Area2D

@export var dps: float = 2

var _direction: Direction
var _original_hitbox_x: float

func set_direction(direction: Direction) -> void:
	_direction = direction
	_original_hitbox_x = $CollisionShape2D.position.x
	_align()

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		for child in body.get_children():
			if child is Health:
				child.take_damage(dps * delta, Vector2(_direction.scalar, 0))
	_align()

func _align() -> void:
	$CollisionShape2D.position.x = _original_hitbox_x * _direction.scalar
