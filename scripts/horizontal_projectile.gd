class_name HorizontalProjectile extends Area2D

@export var velocity: Vector2
@export var damage: float = 15.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func fire(angle: float):
	velocity = velocity.rotated(angle)

func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	for child in body.get_children():
		if child is Health:
			child.take_damage(damage, velocity.normalized())
	if body is TileMapParticles:
		body.hit_tilemap(global_position, velocity.normalized())
	queue_free()
