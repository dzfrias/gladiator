class_name HorizontalProjectile extends StaticBody2D

@export var velocity: Vector2
@export var damage: float = 15.0

func fire(angle: float):
	velocity = velocity.rotated(angle)
	rotation = angle

func _process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision == null:
		return
	var collider := collision.get_collider()
	if collider is Node2D:
		for child in collider.get_children():
			if child is Health:
				child.take_damage(damage, velocity.normalized())
			elif child is HitTarget:
				child.hit(global_position, velocity.normalized())
	queue_free()
