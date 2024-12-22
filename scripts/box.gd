extends RigidBody2D

func _on_health_damage_taken(amount: float) -> void:
	print("Ow")

func _on_health_died() -> void:
	print("Im dead now")
	queue_free()
