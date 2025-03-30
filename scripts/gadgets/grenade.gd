class_name Grenade extends RigidBody2D

@export var explode_on_impact: bool = false
@export var explosion_scene: PackedScene = preload("res://scenes/explosion.tscn")
@export var explosion_time: float = 2
@export var damage: float = 3
@export var throw_force: float = 12000
@export var launch_angle: float = 0.0

func init(direction: Direction) -> void:
	var angle := 0.0 if direction.is_right else PI
	fire(angle)

func fire(angle: float) -> void:
	var norm_angle := angle - 2 * PI * floorf(angle / (2 * PI))
	var k: float
	# If in the second or third quadrant, the launch angle factor should be -1
	if norm_angle > PI / 2 and norm_angle < (3 * PI) / 2:
		k = 1
	else:
		k = -1
	apply_force(Vector2.RIGHT.rotated(angle + launch_angle * k) * throw_force)

func _ready() -> void:
	if explode_on_impact:
		set_contact_monitor(true)
		max_contacts_reported = 1
		body_entered.connect(_body_entered)
	else:
		await get_tree().create_timer(explosion_time).timeout
		_explode()

func _explode():
	var explosion := explosion_scene.instantiate() as Explosion
	explosion.damage = damage
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	queue_free()

func _body_entered(_body: Node2D):
	_explode()
