class_name Projectile extends Node2D

@export var area2D: Area2D
@export var speed: float
var _damage
var _direction

func _ready() -> void:
	area2D.body_entered.connect(_on_body_entered)
	area2D.area_entered.connect(_on_area_entered)

func _set_direction(direction):
	_direction = direction

func _set_damage(damage):
	_damage = damage

func _process(delta: float) -> void:
	global_position.x += _direction.x * speed

func _on_body_entered(body: Node2D):
	for child in body.get_children():
		if child is Health:
			var health = child as Health
			health.take_damage(_damage, _direction)
	queue_free()

func _on_area_entered(area: Area2D):
	for child in area.get_children():
		if child is Health:
			var health = child as Health
			health.take_damage(_damage, _direction)
	queue_free()
