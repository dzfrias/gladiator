extends AnimatedSprite2D

var _shooter: Shooter

func _ready() -> void:
	_shooter = get_parent() as Shooter

func _process(_delta: float) -> void:
	flip_h = _shooter.direction().is_right
	if abs(_shooter.velocity.x) > 0 and _shooter.is_on_floor():
		play("walk")
	else:
		play("idle")
