extends Node2D

@export var wolf_prefab: PackedScene
@export var vulture_prefab: PackedScene
@export var spawn_positions: Array[Node2D]
@export var spawn_delay: float = 10
@export var enemy_group: Node2D

var can_spawn: bool = true

func _process(delta: float) -> void:
	if can_spawn:
		spawn_enemies()

func spawn_enemies():
	can_spawn = false
	if enemy_group.get_child_count() <= 4:
		instantiate_enemies(1, 1)
	await get_tree().create_timer(spawn_delay).timeout
	can_spawn = true

func instantiate_enemies(wolf_amount: int, vulture_amount: int):
	for i in range(wolf_amount):
		var wolf = wolf_prefab.instantiate()
		var random_index = randi_range(0, spawn_positions.size() - 1)
		var spawn_position = spawn_positions[random_index].global_position
		wolf.global_position = spawn_position
		wolf._always_tracking = true
		enemy_group.add_child(wolf)
	
	for i in range(vulture_amount):
		var vulture = vulture_prefab.instantiate()
		var random_index = randi_range(0, spawn_positions.size() - 1)
		var spawn_position = spawn_positions[random_index].global_position
		vulture.global_position = spawn_position
		vulture._always_tracking = true
		enemy_group.add_child(vulture)
