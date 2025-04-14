class_name LightningStrike extends Area2D

@export var damage: float = 7.0

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		for child in body.get_children():
			if child is Health:
				var xdist := global_position.x - body.global_position.x
				child.take_damage(damage, Vector2(signf(xdist), 0))
	
	queue_free()
