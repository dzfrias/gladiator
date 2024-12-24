extends Node2D

@export var tilemap: ProceduralGeneration

@export var wolf_scene: PackedScene
@export var vulture_scene: PackedScene

@export var wolf_spawn_height = 1
@export var vulture_spawn_height = 3

@export var wolf_spawn_chance: float = 0.06
@export var vulture_spawn_chance: float = 0.06

@export var x_pos_padding = 10

func _ready() -> void:
	for x in range(x_pos_padding, tilemap.get_x_distance() - x_pos_padding):
		spawn_enemies_with_chance(x, tilemap.get_ground_height(x))

func spawn_enemies_with_chance(x, ground):
	spawn_enemy_with_chance(wolf_scene, x, wolf_spawn_chance, ground, wolf_spawn_height)
	spawn_enemy_with_chance(vulture_scene, x, vulture_spawn_chance, ground, vulture_spawn_height)

func spawn_enemy_with_chance(enemy_scene: PackedScene, x_pos: int, spawn_chance: float, ground_height: int, spawn_height: int = 1):
	if randf_range(0, 1) < spawn_chance:
		var enemy = enemy_scene.instantiate()
		enemy.global_position = to_global(tilemap.map_to_local(Vector2(x_pos, ground_height - spawn_height)))
		get_tree().root.add_child.call_deferred(enemy)
