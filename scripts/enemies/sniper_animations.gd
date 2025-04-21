extends AnimatedSprite2D

var _sniper: Sniper

func _ready() -> void:
	_sniper = get_parent() as Sniper

func _process(_delta: float) -> void:
	flip_h = _sniper.direction().is_right
	if abs(_sniper.velocity.x) > 0 and _sniper.is_on_floor():
		play("walk")
	else:
		play("idle")
