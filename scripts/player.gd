class_name Player extends CharacterBody2D

@export var move_speed: float = 400
@export var jump_speed: float = 500
@export var roll_speed: float = 800
@export var weapon: Weapon
@export var health: Health

var _state := State.CONTROL
var _direction: float = 1
static var Instance
@onready var _init_layer = collision_layer

enum State {
	CONTROL,
	ROLL,
}

func _ready() -> void:
	$RollTimer.timeout.connect(_on_roll_timer_timeout)
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
	if event.is_action_pressed("fire"):
		$Weapon.set_firing(true)
	if event.is_action_released("fire"):
		$Weapon.set_firing(false)
	if is_on_floor():
		if event.is_action_pressed("jump"):
			velocity.y = -jump_speed
		if event.is_action_pressed("roll"):
			_state = State.ROLL
			$RollTimer.start()
			collision_layer = Constants.INVINCIBLE_LAYER
	if event.is_action_pressed("reload"):
		if !weapon.is_reloading:
			weapon.reload()

func damage(amount: float) -> void:
	if $Health.has_died:
		return
	print("Player hit")
	$Health.take_damage(amount)

func _on_health_died() -> void:
	print("The player has died")

func _on_roll_timer_timeout() -> void:
	collision_layer = _init_layer
	_state = State.CONTROL
	
func get_weapon() -> Weapon:
	return weapon
	
func get_health() -> Health:
	return health;
