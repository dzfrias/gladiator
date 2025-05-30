class_name DeathSpawner extends Node2D

@export var health: Health
@export var spawn_chance: float = 0.4
@export var drops: Array[PackedScene]

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
	var drop = drops[randi_range(0, drops.size() - 1)].instantiate()
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
