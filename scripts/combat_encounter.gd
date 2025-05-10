class_name CombatEncounter extends Module

@export var boundary_tolerance: float = 400.0
@export var initial_spawn_min: int = 2
@export var initial_spawn_max: int = 4
@export var spawn_during_wave_min: int = 4
@export var spawn_during_wave_max: int = 7
@export var spawn_in_cooldown: float = 3.5
@export var spawn_in_delay_mean: float = 0.7
@export var spawn_in_delay_sd: float = 0.1
@export var spawn_in_tired_time: float = 1.5
@export var will_spawn_chest: bool = false
@export var chest_scene: PackedScene = preload("res://scenes/chest.tscn")

class EnemyScene:
	var scene: PackedScene
	var weight: int
	
	func _init(scene: String, weight: int) -> void:
		self.scene = load(scene)
		self.weight = weight

var _started := false
var _spawn_during_wave: int
var _initial_spawn_amt: int
var _left_body: StaticBody2D
var _right_body: StaticBody2D
var _enemies := [
	EnemyScene.new("res://scenes/wolf.tscn", 2),
	EnemyScene.new("res://scenes/shooter.tscn", 3),
]
var _last_spawned: PackedScene
var _done := false
var _idle_shooter: PackedScene = preload("res://scenes/idle_shooter.tscn")
@onready var _group_name = "enemies %s" % get_instance_id()

func _ready() -> void:
	super()
	
	if PersistentData.level > 0:
		_enemies.append(EnemyScene.new("res://scenes/sniper.tscn", 1))
	if PersistentData.level > 2:
		_enemies.append(EnemyScene.new("res://scenes/suispider.tscn", 1))
	if PersistentData.level > 3:
		_enemies.append(EnemyScene.new("res://scenes/burrower.tscn", 1))
	
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
	if not _started or _done:
		return
	
	# Check if all enemies have been killed and there are no more enemies left to spawn
	if get_tree().get_node_count_in_group(_group_name) == 0 and _spawn_during_wave == 0:
		_set_barriers_enabled(false)
		MissionManager.mission.in_combat = false
		if will_spawn_chest:
			_spawn_chest()
		_done = true

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
	if body is not Player or _started or _done:
		return
	_start_wave.call_deferred()

func _start_wave() -> void:
	assert(not _started)
	_started = true
	_set_barriers_enabled(true)
	_spawn_in()
	MissionManager.mission.in_combat = true

func _spawn_in() -> void:
	assert(_started)
	var spawn_points := $SpawnPoints.get_children()
	var last_spawn_point: Node2D = null
	while _spawn_during_wave > 0:
		var enemies_left := get_tree().get_node_count_in_group(_group_name)
		var alive_ratio := float(enemies_left) / float(_initial_spawn_amt)
		
		var to_spawn := 0
		if alive_ratio < 0.2:
			to_spawn = 3
		elif alive_ratio < 0.5:
			to_spawn = 2
		elif alive_ratio < 1.0:
			to_spawn = 1
		to_spawn = mini(to_spawn, _spawn_during_wave)
		_spawn_during_wave -= to_spawn
		assert(_spawn_during_wave >= 0)
		
		for _i in range(to_spawn):
			var spawn_point: Node2D = null
			while spawn_point == null or spawn_point == last_spawn_point:
				spawn_point = spawn_points[randi_range(0, spawn_points.size() - 1)]
			last_spawn_point = spawn_point
			var enemy := _spawn(spawn_point as Node2D)
			# Automatically track player after being spawned
			enemy.notify()
			enemy.spawn_in(spawn_in_tired_time)
			await get_tree().create_timer(randfn(spawn_in_delay_mean, spawn_in_delay_sd)).timeout
		
		await get_tree().create_timer(spawn_in_cooldown).timeout

func _set_barriers_enabled(enabled: bool) -> void:
	_left_body.get_child(0).disabled = !enabled
	_right_body.get_child(0).disabled = !enabled

func _spawn_enemies() -> void:
	var spawn_points := $SpawnPoints.get_children()
	spawn_points.shuffle()
	_initial_spawn_amt = randi_range(initial_spawn_min, initial_spawn_max)
	for i in range(_initial_spawn_amt):
		var spawn_point := spawn_points[i] as Node2D
		_spawn(spawn_point)

func _spawn(spawn_point: Node2D) -> Node2D:
	var enemy_scene: PackedScene = _choose_enemy()
	
	var enemy_instance := enemy_scene.instantiate() as Node2D
	enemy_instance.position = to_global(spawn_point.position)
	enemy_instance.add_to_group(_group_name)
	enemy_instance.add_to_group("enemy")
	get_tree().current_scene.add_child(enemy_instance)
	for child in enemy_instance.get_children():
		if child is Health:
			child.damage_taken.connect(_on_enemy_damage_taken)
	
	return enemy_instance

func _spawn_chest() -> void:
	assert(will_spawn_chest)
	var chest := chest_scene.instantiate() as Node2D
	var spawn_point_index := randi_range(0, $SpawnPoints.get_child_count() - 1)
	var spawn_point := $SpawnPoints.get_children()[spawn_point_index] as Node2D
	chest.position = to_global(spawn_point.position)
	get_tree().current_scene.add_child(chest)

func _on_enemy_damage_taken(_amount: float, _direction: Vector2) -> void:
	if _started:
		return
	_start_wave()

func _choose_enemy() -> PackedScene:
	var scene: PackedScene = null
	var sum = _enemies.reduce(func(accum, x): return x.weight + accum, 0)
	while scene == null or scene == _last_spawned:
		var normalized = _enemies.map(func(x): return WorldMap.WeightedScene.new(x.scene.resource_path, float(x.weight) / float(sum)))
		scene = WorldMap.weighted_choice(normalized).scene
	_last_spawned = scene
	return scene
