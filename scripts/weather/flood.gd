class_name Flood extends Node2D

@export var cycle_off_mean_time := 10.0
@export var cycle_off_sd := 2.5
@export var cycle_on_mean_time := 9.0
@export var cycle_on_sd := 1.5
@export var gravity_strength := 300.0
@export var flood_effects: PackedScene = preload("res://scenes/flood_effects.tscn")

func _ready() -> void:
	_cycle()

func _cycle():
	var world_space := get_viewport().find_world_2d().space
	var original_gravity = PhysicsServer2D.area_get_param(world_space, PhysicsServer2D.AREA_PARAM_GRAVITY)
	while true:
		var wait_time := randfn(cycle_off_mean_time, cycle_off_sd)
		var timer = get_tree().create_timer(wait_time)
		await timer.timeout
		if not MissionManager.mission.in_combat:
			continue
		var effects = flood_effects.instantiate()
		get_tree().current_scene.add_child(effects)
		PhysicsServer2D.area_set_param(world_space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity_strength)
		var on_time = randfn(cycle_on_mean_time, cycle_on_sd)
		timer = get_tree().create_timer(on_time)
		await timer.timeout
		effects.queue_free()
		PhysicsServer2D.area_set_param(world_space, PhysicsServer2D.AREA_PARAM_GRAVITY, original_gravity)
