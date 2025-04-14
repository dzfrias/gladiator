class_name AmmoCollectable extends StaticBody2D

@export var max_ammo_divisor: float = 4.0

func _process(_delta: float) -> void:
	var collision := move_and_collide(Vector2.ZERO)
	if collision == null or collision.get_collider() is not Player:
		return
	
	queue_free()
	var player := collision.get_collider() as Player
	if player.alt_weapon() == null:
		return
	var alt_max := player.alt_weapon().weapon_stats.max_ammo
	if alt_max <= 0:
		return
	var amt := int(alt_max / max_ammo_divisor)
	player.alt_weapon().add_ammo(amt)
