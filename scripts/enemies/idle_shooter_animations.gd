extends AnimatedSprite2D

@export var shooter: IdleShooter

func _ready() -> void:
	shooter.on_state_changed.connect(_on_state_changed)

func _process(_delta: float) -> void:
	flip_h = get_node("../Direction").is_right

func _on_state_changed(state):
	if state == IdleShooter.State.HIDING:
		play("hide")
	elif state == IdleShooter.State.SHOOTING:
		play("shoot")
	elif IdleShooter.State.STANDING:
		play("stand")
