extends RigidBody2D

@export var impact_grenade_prefab: PackedScene
@export var airstrike_time = 3
@export var damage = 2
@export var bombs = 8
@export var bomb_interval = 0.3
@export var x_variance = 100

@onready var airstrike_location = $AirstrikeLocation

func _ready() -> void:
	await get_tree().create_timer(airstrike_time).timeout
	_launch_airstrike()

func _launch_airstrike():
	for i in range(bombs):
		var impact_grenade = impact_grenade_prefab.instantiate() as Grenade
		impact_grenade.damage = damage
		impact_grenade.explode_on_impact = true
		get_tree().current_scene.add_child(impact_grenade)
		impact_grenade.global_position = airstrike_location.global_position
		impact_grenade.global_position.x += randf_range(-x_variance, x_variance)
		await get_tree().create_timer(bomb_interval).timeout
	queue_free()
