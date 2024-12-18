extends CharacterBody2D

@export var move_speed : float = 10000

func _process(delta: float) -> void:
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		velocity.x = 0
	elif Input.is_action_pressed("left"):
		velocity.x = -move_speed * delta
	elif Input.is_action_pressed("right"):
		velocity.x = move_speed * delta
	else:
		velocity.x = 0
	move_and_slide()
