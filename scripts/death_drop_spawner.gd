class_name DeathSpawner extends Node2D

@export var health: Health
@export var spawn_chance: float = 0.2
@export var death_drop_scene: PackedScene

func _ready() -> void:
	if health == null:
		for child in get_parent().get_children():
			if child is Health:
				health = child
				break
	assert(spawn_chance <= 1.0 and spawn_chance >= 0.0)
	
	health.died.connect(_on_health_died)

func _on_health_died() -> void:
	if randf() > spawn_chance:
		return
	var drop = death_drop_scene.instantiate()
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
