extends Node

@export_range(0, 1) var drop_chance = 0.25
@export var ammo_drop: PackedScene

func _ready() -> void:
	var health = get_parent().get_node("Health")
	health.died.connect(on_death)

func on_death():
	if randf_range(0, 1) <= drop_chance:
		var ammo = ammo_drop.instantiate()
		get_tree().current_scene.add_child(ammo)
		ammo.global_position = get_parent().global_position
