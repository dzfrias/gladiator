class_name Player extends CharacterBody2D

@export var move_speed: float = 400
@export var move_acceleration: float = 2000
@export var move_deceleration: float = 2000
@export var crouch_move_speed: float = 200
@export var direction_change_factor: float = 3
@export var jump_speed: float = 500
@export var jump_accel: float = 1000
@export var jump_hold_time: float = 0.5
@export var jump_buffer_time: float = 0.2
@export var gravity_scale: float = 2.0
@export var roll_speed: float = 1200
@export var roll_time: float = 0.2
@export var roll_cooldown_time: float = 0.4
@export var invincible_time: float = 1.0

@onready var standing_hitbox = $StandingHitbox
@onready var crouching_hitbox = $CrouchingHitbox
@onready var standing_sprite = $StandingSprite
@onready var crouching_sprite = $CrouchingSprite
@onready var standing_item_position = $StandingItemPosition
@onready var crouching_item_position = $CrouchingItemPosition
@onready var _item_position = $ItemPosition
@onready var direction = $Direction

# NOTE this field can be null (if the player has no weapon)
@onready var _weapon: Weapon = $Weapon
var _current_item
var _items: Array
var _state := State.CONTROL
var _can_roll := true
var _is_crouching := false
var _is_jumping := false
var _jump_time := 0.0
var _jump_buffer := 0.0
static var Instance

signal on_item_switched(current_item)

enum State {
	CONTROL,
	ROLL,
}

func _ready() -> void:
	_items.append(_weapon)
	_items.append(load("res://scenes/gadgets/grenade.tscn"))
	
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	Instance = self
	_current_item = _weapon
	_item_position.position = standing_item_position.position

func _process(delta: float) -> void:
	if _is_jumping and _jump_time < jump_hold_time:
		velocity.y -= jump_accel * delta
		_jump_time += delta
	elif not is_on_floor():
		velocity.y += get_gravity().y * gravity_scale * delta
	if _jump_buffer > 0:
		_jump_buffer = max(0, _jump_buffer - delta)
		if _state == State.CONTROL and is_on_floor():
			_is_jumping = true
			velocity.y = -jump_speed
		
	match _state:
		State.CONTROL:
			if Input.is_action_pressed("crouch") and Input.is_action_pressed("jump"):
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
			else:
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
			
			if Input.is_action_just_pressed("crouch"):
				_is_crouching = true
				standing_hitbox.disabled = true
				standing_sprite.visible = false
				crouching_hitbox.disabled = false
				crouching_sprite.visible = true
			elif !Input.is_action_pressed("crouch") and _is_crouching:
				_is_crouching = false
				standing_hitbox.disabled = false
				standing_sprite.visible = true
				crouching_hitbox.disabled = true
				crouching_sprite.visible = false
			
			if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
				velocity.x = move_toward(velocity.x, 0, move_acceleration * delta)
			elif Input.is_action_pressed("left"):
				var acceleration := move_acceleration
				# This will make the movement snappier if the player wants to
				# change directions
				if velocity.x > 0:
					acceleration *= direction_change_factor
				if _is_crouching:
					velocity.x = maxf(-crouch_move_speed, velocity.x - acceleration * delta)
				else:
					velocity.x = maxf(-move_speed, velocity.x - acceleration * delta)
				direction.is_right = false
			elif Input.is_action_pressed("right"):
				var acceleration := move_acceleration
				if velocity.x < 0:
					acceleration *= direction_change_factor
				if _is_crouching:
					velocity.x = minf(crouch_move_speed, velocity.x + acceleration * delta)
				else:
					velocity.x = minf(move_speed, velocity.x + acceleration * delta)
				direction.is_right = true
			else:
				velocity.x = move_toward(velocity.x, 0, move_deceleration * delta)
			
			if _is_crouching:
				_item_position.position = crouching_item_position.position
			else:
				_item_position.position = standing_item_position.position
			_item_position.position = Vector2(_item_position.position.x * direction.scalar, _item_position.position.y)
			_weapon.position = _item_position.position
		State.ROLL:
			velocity.x = roll_speed * $Direction.scalar
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	
	if event.as_text().is_valid_int():
		var index := event.as_text().to_int() - 1
		if index < _items.size():
			_current_item = _items[index]
			on_item_switched.emit(_current_item)
			print(_items[index])
	
	if _state != State.CONTROL:
		return
	if event.is_action_pressed("fire"):
		if _current_item == _weapon:
			_weapon.set_firing($Direction)
		else:
			throw(_current_item)
	if event.is_action_released("fire"):
		if _current_item == _weapon:
			_weapon.set_firing(null)
	if is_on_floor():
		if event.is_action_pressed("jump") and !Input.is_action_pressed("crouch"):
			_is_jumping = true
			velocity.y = -jump_speed
	elif event.is_action_pressed("jump"):
		_jump_buffer = jump_buffer_time
	if _is_jumping and event.is_action_released("jump"):
		_is_jumping = false
		_jump_time = 0.0
	if event.is_action_pressed("roll") and _can_roll:
		_roll()
	if event.is_action_pressed("reload") and _weapon:
		if !_weapon.is_reloading:
			_weapon.reload()

func damage(amount: float, direction: Vector2) -> void:
	if $Health.has_died or collision_layer == Constants.INVINCIBLE_LAYER:
		return
	print("Player hit")
	$Health.take_damage(amount, direction)

func _freeze_time():
	get_tree().paused = true
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false

func _roll() -> void:
	_state = State.ROLL
	_is_jumping = false
	_jump_buffer = 0.0
	if _weapon:
		_weapon.set_firing(null)
	collision_layer = Constants.INVINCIBLE_LAYER
	$StandingSprite.flip_v = true
	$CrouchingSprite.flip_v = true
	await get_tree().create_timer(roll_time).timeout
	_state = State.CONTROL
	velocity.x *= 0.4
	$StandingSprite.flip_v = false
	$CrouchingSprite.flip_v = false
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
	_can_roll = false
	await get_tree().create_timer(roll_cooldown_time).timeout
	_can_roll = true

func _on_health_died() -> void:
	print("The player has died")

func _on_health_damage_taken(_amount: int, _direction: Vector2) -> void:
	_freeze_time()
	collision_layer = Constants.INVINCIBLE_LAYER
	_flash_invincible()
	await get_tree().create_timer(invincible_time).timeout
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER

func is_holding_weapon() -> bool:
	return _weapon == _current_item

func get_current_item() -> Node2D:
	return _current_item

func is_on_platform():
	return $PlatformRaycast.is_colliding()

func get_platform_height():
	return $PlatformRaycast.get_collision_point().y

func _flash_invincible() -> void:
	while collision_layer == Constants.INVINCIBLE_LAYER:
		standing_sprite.visible = false
		crouching_sprite.visible = false
		await get_tree().create_timer(0.05).timeout
		standing_sprite.visible = !_is_crouching
		crouching_sprite.visible = _is_crouching
		await get_tree().create_timer(0.05).timeout

func throw(throwable_prefab: PackedScene):
	var throwable = throwable_prefab.instantiate()
	throwable.global_position = _item_position.global_position
	get_tree().current_scene.add_child(throwable)
	throwable.apply_force(Vector2(direction.scalar * 12000, -12000))
	print("Throw")
	
func get_health() -> Health:
	return $Health;
