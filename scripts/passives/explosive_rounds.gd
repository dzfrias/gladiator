extends Node

@export var count: int = 5
@export var explosion_scene: PackedScene

@onready var _current = count

func _ready() -> void:
	await get_tree().process_frame
	Player.Instance.weapon().fired.connect(_on_weapon_fired)
	Player.Instance.alt_weapon_node().fired.connect(_on_weapon_fired)

func _on_weapon_fired(projectile: Node2D) -> void:
	_current -= 1
	if _current > 0:
		return
	
	_current = count
	if projectile.has_signal("hit"):
		projectile.hit.connect(_create_explosion.bind(projectile))

func _create_explosion(projectile: Node2D) -> void:
	var explosion := explosion_scene.instantiate() as Explosion
	explosion.exceptions.append(Player.Instance)
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = projectile.global_position
