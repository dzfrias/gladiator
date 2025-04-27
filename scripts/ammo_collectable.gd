class_name AmmoCollectable extends Area2D

@export var max_ammo_divisor: float = 4.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is not Player:
		return
	
	queue_free()
	var player := body as Player
	if player.alt_weapon() == null:
		return
	var alt_max := player.alt_weapon().weapon_stats.max_ammo
	if alt_max <= 0:
		return
	var amt := int(alt_max / max_ammo_divisor)
	player.alt_weapon().add_ammo(amt)
