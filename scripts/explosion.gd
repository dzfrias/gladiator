class_name Explosion extends Area2D

@export var damage: float = 7.0
@export var camera_trauma: float = 0.8
@export var auto_free: bool = false

var exceptions: Array[Node]

func _ready() -> void:
	await get_tree().process_frame  # Ensures all nodes are added
	await get_tree().physics_frame  # Ensures physics is running
	
	for body in get_overlapping_bodies():
		if body in exceptions:
			continue
		for child in body.get_children():
			if child is Health:
				child.take_damage(damage, Vector2.ZERO)
	
	Player.Instance.camera().add_trauma(camera_trauma)
	
	if auto_free:
		queue_free()
