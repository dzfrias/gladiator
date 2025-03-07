extends RigidBody2D

@export var explosion_prefab: PackedScene
@export var explosionTime = 2
@export var damage = 3

@onready var explosion_radius = $ExplosionRadius
var direction: Direction

func _ready() -> void:
	await get_tree().create_timer(explosionTime).timeout
	_explode()

func _explode():
	var explosion = explosion_prefab.instantiate() as Explosion
	explosion.damage = damage
	explosion.global_position = global_position
	print("set position")
	get_tree().current_scene.add_child(explosion)
	queue_free()
