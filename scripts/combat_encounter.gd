class_name CombatEncounter extends Module

@export var wave_delay: float = 6.0
@export var spawn_delay_mean: float = 0.8
@export var spawn_delay_sd: float = 0.1
@export var boundary_tolerance := 400

var _started := false
var _finished_spawning := false
var _left_body: StaticBody2D
var _right_body: StaticBody2D
var _enemies := [
	WorldMap.WeightedScene.new("res://scenes/wolf.tscn", 0.5),
	WorldMap.WeightedScene.new("res://scenes/shooter.tscn", 0.25),
	WorldMap.WeightedScene.new("res://scenes/suispider.tscn", 0.25),
]
var _idle_shooter: PackedScene = preload("res://scenes/idle_shooter.tscn")
@onready var _group_name = "enemies %s" % get_instance_id()

func _ready() -> void:
	super()
	
	# Create a "start area" trigger that will start the wave when the player enters
	var start_area := Area2D.new()
	start_area.monitorable = false
	start_area.collision_layer = 0
	start_area.collision_mask = Constants.PLAYER_LAYER | Constants.INVINCIBLE_LAYER
	start_area.body_entered.connect(_on_body_entered)
	var start_shape := CollisionShape2D.new()
	var shape := WorldBoundaryShape2D.new()
	shape.normal = Vector2(-1, 0)
	start_shape.shape = shape
	start_area.add_child(start_shape)
	add_child(start_area)
	
	_left_body = _create_boundary(1)
	_right_body = _create_boundary(-1)
	add_child(_left_body)
	add_child(_right_body)
	_left_body.position.x = -boundary_tolerance
	_right_body.position.x = right_boundary + boundary_tolerance

func _process(_delta: float) -> void:
	if not _started or not _finished_spawning:
		return
	
	# Check if all enemies have been killed
	if get_tree().get_nodes_in_group(_group_name).is_empty():
		_set_barriers_enabled(false)

static func _create_boundary(x: float) -> StaticBody2D:
	var boundary := StaticBody2D.new()
	boundary.collision_layer = Constants.ENVIRONMENT_LAYER
	boundary.collision_mask = Constants.PLAYER_LAYER
	var collision_shape := CollisionShape2D.new()
	collision_shape.disabled = true
	var shape := WorldBoundaryShape2D.new()
	shape.normal = Vector2(x, 0)
	collision_shape.shape = shape
	boundary.add_child(collision_shape)
	return boundary

func _on_body_entered(body: Node2D) -> void:
	if body is not Player or _started:
		return
	_start_wave.call_deferred()

func _start_wave() -> void:
	assert(not _started)
	_started = true
	_set_barriers_enabled(true)
	await get_tree().create_timer(wave_delay).timeout
	
	_finished_spawning = false
	for child in $SpawnPoints.get_children():
		var spawn_point := child as Node2D
		
		var enemy_scene: PackedScene
		match child.get_meta("spawnpoint_type", "any"):
			"idle_ranged":
				enemy_scene = _idle_shooter
			"any":
				enemy_scene = WorldMap.weighted_choice(_enemies).scene
			var type:
				printerr("invalid spawnpoint type: %s" % type)
				continue
		
		var enemy_instance := enemy_scene.instantiate() as Node2D
		enemy_instance.position = to_global(spawn_point.position)
		enemy_instance.add_to_group(_group_name) 
		get_tree().current_scene.add_child(enemy_instance)
		await get_tree().create_timer(randfn(spawn_delay_mean, spawn_delay_sd)).timeout
	_finished_spawning = true

func _set_barriers_enabled(enabled: bool) -> void:
	_left_body.get_child(0).disabled = !enabled
	_right_body.get_child(0).disabled = !enabled
