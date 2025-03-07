extends RigidBody2D

@export var explosionTime = 2
@export var damage = 3

@onready var explosion_radius = $ExplosionRadius
var direction: Direction

func _ready() -> void:
	await get_tree().create_timer(explosionTime).timeout
	_explode()

func _explode():
	for body in explosion_radius.get_overlapping_bodies():
		for child in body.get_children():
			if child is Health:
				child.take_damage(damage, Vector2.ZERO)
	queue_free()
