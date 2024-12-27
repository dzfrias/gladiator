extends Node2D

@export var tilemap: ProceduralGeneration
@export var wolf_scene: PackedScene
@export var vulture_scene: PackedScene
@export var wolf_spawn_chance: float = 0.06
@export var vulture_spawn_chance: float = 0.06
@export var x_pos_padding = 10

func _ready() -> void:
	for x in range(x_pos_padding, tilemap.x_distance - x_pos_padding):
		spawn_enemies_with_chance(x)

func spawn_enemies_with_chance(x: int):
	const WOLF_SPAWN_HEIGHT = 1
	const VULTURE_SPAWN_HEIGHT = 3
	spawn_enemy_with_chance(wolf_scene, x, wolf_spawn_chance, WOLF_SPAWN_HEIGHT)
	spawn_enemy_with_chance(vulture_scene, x, vulture_spawn_chance, VULTURE_SPAWN_HEIGHT)

func spawn_enemy_with_chance(enemy_scene: PackedScene, x_pos: int, spawn_chance: float, spawn_height: int = 1):
	var ground_height := tilemap.get_ground_height(x_pos)
	if randf_range(0, 1) < spawn_chance:
		var enemy = enemy_scene.instantiate()
		enemy.global_position = to_global(tilemap.map_to_local(Vector2(x_pos, ground_height - spawn_height)))
		get_tree().root.get_child(-1).add_child.call_deferred(enemy)
