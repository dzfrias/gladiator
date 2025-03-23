class_name CombatEncounter extends Module

@export var boundary_tolerance: float = 400.0
@export var spawn_during_wave_min: int = 4
@export var spawn_during_wave_max: int = 7
@export var spawn_in_cooldown: float = 3.5
@export var spawn_in_delay_mean: float = 0.7
@export var spawn_in_delay_sd: float = 0.1
@export var spawn_in_tired_time: float = 1.5

var _started := false
var _spawn_during_wave: int
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
	
	_spawn_during_wave = randi_range(spawn_during_wave_min, spawn_during_wave_max)
	_spawn_enemies.call_deferred()

func _process(_delta: float) -> void:
	if not _started:
		return
	
	# Check if all enemies have been killed and there are no more enemies left to spawn
	if get_tree().get_node_count_in_group(_group_name) and _spawn_during_wave == 0:
		_set_barriers_enabled(false)

static func _create_boundary(x: float) -> StaticBody2D:
	var boundary := StaticBody2D.new()
	boundary.collision_layer = Constants.PLAYER_BOUNDARY_LAYER
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
	_spawn_in()

func _spawn_in() -> void:
	assert(_started)
	var spawn_points := $SpawnPoints.get_children()
	while _spawn_during_wave > 0:
		var enemies_left := get_tree().get_node_count_in_group(_group_name)
		var alive_ratio := float(enemies_left) / float(spawn_points.size())
		
		var to_spawn := 0
		if alive_ratio < 0.2:
			to_spawn = 3
		elif alive_ratio < 0.7:
			to_spawn = 2
		elif alive_ratio < 1.0:
			to_spawn = 1
		to_spawn = mini(to_spawn, _spawn_during_wave)
		_spawn_during_wave -= to_spawn
		assert(_spawn_during_wave >= 0)
		
		for _i in range(to_spawn):
			var choice := randi_range(0, spawn_points.size() - 1)
			var enemy := _spawn(spawn_points[choice], false)
			# Automatically track player after being spawned
			enemy.notify()
			enemy.make_tired(spawn_in_tired_time)
			await get_tree().create_timer(randfn(spawn_in_delay_mean, spawn_in_delay_sd)).timeout
		
		await get_tree().create_timer(spawn_in_cooldown).timeout

func _set_barriers_enabled(enabled: bool) -> void:
	_left_body.get_child(0).disabled = !enabled
	_right_body.get_child(0).disabled = !enabled

func _spawn_enemies() -> void:
	for child in $SpawnPoints.get_children():
		var spawn_point := child as Node2D
		_spawn(spawn_point)

func _spawn(spawn_point: Node2D, allow_meta: bool = true) -> Node2D:
	var enemy_scene: PackedScene
	if allow_meta:
		match spawn_point.get_meta("spawnpoint_type", "any"):
			"idle_ranged":
				enemy_scene = _idle_shooter
			"any":
				enemy_scene = WorldMap.weighted_choice(_enemies).scene
			var type:
				printerr("invalid spawnpoint type: %s" % type)
				return
	else:
		enemy_scene = WorldMap.weighted_choice(_enemies).scene
	
	var enemy_instance := enemy_scene.instantiate() as Node2D
	enemy_instance.position = to_global(spawn_point.position)
	enemy_instance.add_to_group(_group_name)
	enemy_instance.add_to_group("enemy")
	get_tree().current_scene.add_child(enemy_instance)
	return enemy_instance
