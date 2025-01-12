class_name Player extends CharacterBody2D

@export var move_speed: float = 400
@export var move_acceleration: float = 2000
@export var direction_change_factor: float = 3
@export var jump_speed: float = 500
@export var roll_speed: float = 800
@export var roll_time: float = 0.2
@export var roll_cooldown_time: float = 0.4

# NOTE this field can be null (if the player has no weapon)
var _weapon: Weapon
var _state := State.CONTROL
var _direction: float = 1
var _can_roll := true
static var Instance

signal weapon_changed

enum State {
	CONTROL,
	ROLL,
}

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	Instance = self
	_weapon = $Weapon

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	match _state:
		State.CONTROL:
			if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
				velocity.x = move_toward(velocity.x, 0, move_acceleration * delta)
			elif Input.is_action_pressed("left"):
				var acceleration := move_acceleration
				# This will make the movement snappier if the player wants to
				# change directions
				if velocity.x > 0:
					acceleration *= direction_change_factor
				velocity.x = max(-move_speed, velocity.x - acceleration * delta)
				_direction = -1
			elif Input.is_action_pressed("right"):
				var acceleration := move_acceleration
				if velocity.x < 0:
					acceleration *= direction_change_factor
				velocity.x = min(move_speed, velocity.x + acceleration * delta)
				_direction = 1
			else:
				velocity.x = move_toward(velocity.x, 0, move_acceleration * delta)
		State.ROLL:
			velocity.x = roll_speed * _direction
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if _state != State.CONTROL:
		return
	if event.is_action_pressed("fire") and _weapon:
		_weapon.set_firing(true)
	if event.is_action_released("fire") and _weapon:
		_weapon.set_firing(false)
	if is_on_floor():
		if event.is_action_pressed("jump"):
			velocity.y = -jump_speed
		if event.is_action_pressed("roll") and _can_roll:
			_roll()
	if event.is_action_pressed("reload") and _weapon:
		if !_weapon.is_reloading:
			_weapon.reload()
	if event.is_action_pressed("toggle_weapon"):
		if not _weapon:
			_weapon = $Weapon
		else:
			_weapon.set_firing(false)
			_weapon = null
		weapon_changed.emit()

func damage(amount: float) -> void:
	if $Health.has_died:
		return
	print("Player hit")
	$Health.take_damage(amount)

func _roll() -> void:
	_state = State.ROLL
	assert(collision_layer == Constants.PLAYER_LAYER | Constants.ENTITY_LAYER)
	collision_layer = Constants.INVINCIBLE_LAYER
	await get_tree().create_timer(roll_time).timeout
	_state = State.CONTROL
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
	_can_roll = false
	await get_tree().create_timer(roll_cooldown_time).timeout
	_can_roll = true

func _on_health_died() -> void:
	print("The player has died")

func get_weapon() -> Weapon:
	return _weapon
	
func get_health() -> Health:
	return $Health;
