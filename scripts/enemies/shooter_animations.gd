extends AnimatedSprite2D

@export var shooter: Shooter
var is_tracking = true

func _ready() -> void:
	shooter.on_state_changed.connect(_on_state_changed)

func _process(_delta: float) -> void:
	flip_h = get_node("../Direction").is_right
	if is_tracking:
		if abs(shooter.velocity.x) > 0:
			play("walk")
		else:
			play("idle")

func _on_state_changed(state):
	if state == FollowEnemy.State.TRACKING:
		play("walk")
		is_tracking = true
	elif state == FollowEnemy.State.ATTACKING:
		play("shoot")
		is_tracking = false
	else:
		play("idle")
		is_tracking = false
