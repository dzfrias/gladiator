class_name ShotgunShell extends Node2D

@export var to_spawn: int = 5
@export var child_projectile: PackedScene
@export var angle_sd: float = PI / 128

func fire(angle: float):
	await get_tree().process_frame
	for _i in range(to_spawn):
		var child := child_projectile.instantiate()
		get_tree().current_scene.add_child(child)
		child.global_position = global_position
		child.fire(randfn(angle, angle_sd))
