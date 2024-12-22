class_name Player

extends CharacterBody2D

@export var move_speed: float = 10000
@export var jump_speed: float = 500

func _process(delta: float) -> void:
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		velocity.x = 0
	elif Input.is_action_pressed("left"):
		velocity.x = -move_speed
	elif Input.is_action_pressed("right"):
		velocity.x = move_speed
	else:
		velocity.x = 0

	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = -jump_speed
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		$Weapon.fire(position)

func damage(amount: float) -> void:
	$Health.take_damage(amount)

func _on_health_died() -> void:
	print("The player has died")
