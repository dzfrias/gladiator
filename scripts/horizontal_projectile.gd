class_name HorizontalProjectile extends Area2D

var velocity: Vector2
var damage := 15.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func fire(speed: float, angle: float):
	assert(speed >= 0)
	velocity = Vector2.RIGHT.rotated(angle) * speed

func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	for child in body.get_children():
		if child is Health:
			child.take_damage(damage, velocity.normalized())
	if body is TileMapParticles:
		body.hit_tilemap(global_position, velocity.normalized())
	queue_free()
