extends Node2D

@export var wolf_prefab: PackedScene
@export var vulture_prefab: PackedScene
@export var spawn_positions: Array[Node2D]
@export var spawn_delay: float = 10
@export var enemy_group: Node2D

func _ready() -> void:
	_spawn_enemies_loop()

func _spawn_enemies_loop() -> void:
	while true:
		if enemy_group.get_child_count() <= 4:
			_spawn_enemies()
		await get_tree().create_timer(spawn_delay).timeout

func _spawn_enemies() -> void:
	_spawn(wolf_prefab)
	_spawn(vulture_prefab)

func _spawn(enemy: PackedScene) -> void:
	var instance := enemy.instantiate()
	var random_index := randi_range(0, spawn_positions.size() - 1)
	var spawn_position := spawn_positions[random_index].global_position
	instance.global_position = spawn_position
	instance.track(Player.Instance)
	enemy_group.add_child(instance)
