class_name HurtBubble extends StaticBody2D

@export var speed: float = 200.0
@export var damage: float = 3.0
@export var scale_min: float = 3.0
@export var scale_max: float = 8.0

@onready var _original_x = position.x

func _ready() -> void:
	scale = Vector2.ONE * randf_range(scale_min, scale_max)

func _process(delta: float) -> void:
	
	var collision := move_and_collide(Vector2.UP * speed * delta)
	if collision == null:
		return
	if collision.get_collider() is Player:
		var player := collision.get_collider() as Player
		player.get_health().take_damage(damage, Vector2.UP)
