extends CharacterBody2D

@export var move_speed : float = 10000
@export var jump_speed : float = 500

@export var weapon : Weapon

func _process(delta: float) -> void:
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		velocity.x = 0
	elif Input.is_action_pressed("left"):
		velocity.x = -move_speed * delta
	elif Input.is_action_pressed("right"):
		velocity.x = move_speed * delta
	else:
		velocity.x = 0
	
	velocity.y += get_gravity().y * delta
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = -jump_speed
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		weapon.fire(position)
