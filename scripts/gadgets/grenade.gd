class_name Grenade extends RigidBody2D

@export var explode_on_impact = false
@export var explosion_prefab: PackedScene
@export var explosionTime = 2
@export var damage = 3
@export var throw_force = 12000

@onready var explosion_radius = $ExplosionRadius
var direction: Direction

func init(direction: Direction) -> void:
	apply_force(Vector2(direction.scalar * throw_force, -throw_force))

func _ready() -> void:
	if explode_on_impact:
		set_contact_monitor(true)
		max_contacts_reported = 1
		body_entered.connect(_body_entered)
	else:
		await get_tree().create_timer(explosionTime).timeout
		_explode()

func _explode():
	var explosion = explosion_prefab.instantiate() as Explosion
	explosion.damage = damage
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	queue_free()

func _body_entered(body: Node2D):
	_explode()
