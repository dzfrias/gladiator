class_name BulletCase extends StaticBody2D

@export var initial_speed: float = 500.0
@export var angle_sd: float = PI / 32
@export var rps: float = 6 * PI
@export var gravity_factor: float = 3.0

var velocity: Vector2
var _direction: float

func launch(angle: float) -> void:
	velocity = (Vector2.RIGHT * initial_speed).rotated(randfn(angle, angle_sd))
	_direction = signf(velocity.x)

func _process(delta: float) -> void:
	velocity.y += 9.81 * gravity_factor
	
	$Sprite2D.rotation += rps * _direction * delta
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		queue_free()
