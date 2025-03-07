class_name Explosion extends Area2D

var damage = 0

func _ready() -> void:
	await get_tree().process_frame  # Ensures all nodes are added
	await get_tree().physics_frame  # Ensures physics is running
	for body in get_overlapping_bodies():
		for child in body.get_children():
			if child is Health:
				child.take_damage(damage, Vector2.ZERO)
	queue_free()
