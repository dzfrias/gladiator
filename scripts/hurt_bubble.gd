class_name HurtBubble extends StaticBody2D

@export var speed: float = 400.0
@export var damage: float = 3.0

func _process(delta: float) -> void:
	var collision := move_and_collide(Vector2.UP * speed * delta)
	if collision == null:
		return
	if collision.get_collider() is Player:
		var player := collision.get_collider() as Player
		player.get_health().take_damage(damage, Vector2.UP)
