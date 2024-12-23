class_name ArcProjectile extends Area2D

var damage := 5.0

var _velocity: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func fire(speed: float, angle: float):
	assert(speed >= 0)
	_velocity = Vector2.RIGHT.rotated(angle) * speed

func _process(delta: float) -> void:
	_velocity.y += 980 * delta
	position += _velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(damage)
	queue_free()
