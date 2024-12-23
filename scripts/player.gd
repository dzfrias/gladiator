class_name Player extends CharacterBody2D

@export var move_speed: float = 400
@export var jump_speed: float = 500
@export var roll_speed: float = 800
@export var roll_time: float = 0.2
@export var roll_cooldown_time: float = 0.4

var _state := State.CONTROL
var _direction: float = 1
var _can_roll := true
static var Instance
@onready var _init_layer = collision_layer

enum State {
	CONTROL,
	ROLL,
}

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	Instance = self

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	match _state:
		State.CONTROL:
			if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
				velocity.x = 0
			elif Input.is_action_pressed("left"):
				velocity.x = -move_speed
				_direction = -1
			elif Input.is_action_pressed("right"):
				velocity.x = move_speed
				_direction = 1
			else:
				velocity.x = 0
		State.ROLL:
			velocity.x = roll_speed * _direction
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if _state != State.CONTROL:
		return
	if event.is_action_pressed("fire"):
		$Weapon.set_firing(true)
	if event.is_action_released("fire"):
		$Weapon.set_firing(false)
	if is_on_floor():
		if event.is_action_pressed("jump"):
			velocity.y = -jump_speed
		if event.is_action_pressed("roll") and _can_roll:
			_roll()
	if event.is_action_pressed("reload"):
		if !$Weapon.is_reloading:
			$Weapon.reload()

func damage(amount: float) -> void:
	if $Health.has_died:
		return
	print("Player hit")
	$Health.take_damage(amount)

func _roll() -> void:
	_state = State.ROLL
	collision_layer = Constants.INVINCIBLE_LAYER
	await get_tree().create_timer(roll_time).timeout
	_state = State.CONTROL
	collision_layer = _init_layer
	_can_roll = false
	await get_tree().create_timer(roll_cooldown_time).timeout
	_can_roll = true

func _on_health_died() -> void:
	print("The player has died")

func get_weapon() -> Weapon:
	return $Weapon
	
func get_health() -> Health:
	return $Health;
