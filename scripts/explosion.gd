class_name Explosion extends Area2D

@export var damage: float = 7.0
@export var auto_free: bool = false

func _ready() -> void:
	await get_tree().process_frame  # Ensures all nodes are added
	await get_tree().physics_frame  # Ensures physics is running
	
	for body in get_overlapping_bodies():
		for child in body.get_children():
			if child is Health:
				child.take_damage(damage, Vector2.ZERO)
	
	Player.Instance.camera().add_trauma(0.8)
	
	if auto_free:
		queue_free()
