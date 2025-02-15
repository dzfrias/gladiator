extends Node

@export var health_bar_prefab: PackedScene
@export var health: Health

func _ready() -> void:
	spawn.call_deferred()
	
func spawn():
	var health_bar := health_bar_prefab.instantiate()
	health_bar.set_health(health)
	get_tree().current_scene.add_child(health_bar)
