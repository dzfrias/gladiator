class_name HealthBarCreator extends Node

@export var health_bar_prefab: PackedScene = preload("res://scenes/health_bar.tscn")

func _ready() -> void:
	_spawn.call_deferred()
	
func _spawn():
	var health = $"../Health"
	var health_bar := health_bar_prefab.instantiate()
	health_bar.set_health(health)
	get_tree().current_scene.add_child(health_bar)
