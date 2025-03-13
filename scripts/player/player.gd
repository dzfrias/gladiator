class_name Player extends CharacterBody2D

@export var movement_settings: Resource

@onready var standing_hitbox = $StandingHitbox
@onready var crouching_hitbox = $CrouchingHitbox
@onready var standing_sprite = $StandingSprite
@onready var crouching_sprite = $CrouchingSprite
@onready var standing_item_position = $StandingItemPosition
@onready var crouching_item_position = $CrouchingItemPosition
@onready var _item_position = $ItemPosition
@onready var direction = $Direction
@onready var _original_shield_x = $Shield.position.x

# NOTE this field can be null (if the player has no weapon)
@onready var _weapon: Weapon = $Weapon
var _state := State.CONTROL
var _can_roll := true
var _is_crouching := false
var _is_jumping := false
var _jump_time := 0.0
var _jump_buffer := 0.0
@onready var inventory = Inventory.new()
@onready var _current_move_speed = movement_settings.move_speed
static var Instance

enum State {
	CONTROL,
	ROLL,
	UNDERGROUND
}

func _ready() -> void:
	inventory.add_item(_weapon)
	var grenade = load("res://scenes/gadgets/grenade.tscn")
	var airstrike = load("res://scenes/gadgets/airstrike_grenade.tscn")
	var speed_boost = load("res://scenes/gadgets/speed_boost.tscn")
	inventory.add_item(grenade)
	inventory.add_item(airstrike)
	inventory.add_item(speed_boost)
	
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	Instance = self
	_item_position.position = standing_item_position.position

func _process(delta: float) -> void:
	if _is_jumping and _jump_time < movement_settings.jump_hold_time:
		velocity.y -= movement_settings.jump_accel * delta
		_jump_time += delta
	elif not is_on_floor():
		velocity.y += get_gravity().y * movement_settings.gravity_scale * delta
	if _jump_buffer > 0:
		_jump_buffer = max(0, _jump_buffer - delta)
		if _state == State.CONTROL and is_on_floor():
			_is_jumping = true
			velocity.y = -movement_settings.jump_speed
	
	match _state:
		State.CONTROL:
			if Input.is_action_pressed("crouch") and Input.is_action_pressed("jump"):
				if is_on_platform():
					set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
				elif is_on_floor():
					_burrow()
					return
			else:
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
			
			if Input.is_action_just_pressed("crouch") and not $Shield.is_enabled():
				_crouch()
			elif !Input.is_action_pressed("crouch") and _is_crouching:
				_uncrouch()
			if not _is_crouching and not $Shield.is_enabled():
				_current_move_speed = movement_settings.move_speed
			
			_apply_horizontal_movement(delta)
			
			if _is_crouching:
				_item_position.position = crouching_item_position.position
			else:
				_item_position.position = standing_item_position.position
			_item_position.position = Vector2(_item_position.position.x * direction.scalar, _item_position.position.y)
			$Shield.position = Vector2(_original_shield_x * direction.scalar, $Shield.position.y)
			_weapon.position = _item_position.position
		State.ROLL:
			velocity.x = movement_settings.roll_speed * $Direction.scalar
		State.UNDERGROUND:
			_apply_horizontal_movement(delta)
		
	move_and_slide()

func _apply_horizontal_movement(delta: float):
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		velocity.x = move_toward(velocity.x, 0, movement_settings.move_acceleration * delta)
	elif Input.is_action_pressed("left"):
		var acceleration = movement_settings.move_acceleration
		# This will make the movement snappier if the player wants to
		# change directions
		if velocity.x > 0:
			acceleration *= movement_settings.direction_change_factor
		velocity.x = maxf(-_current_move_speed, velocity.x - acceleration * delta)
		direction.is_right = false
	elif Input.is_action_pressed("right"):
		var acceleration = movement_settings.move_acceleration
		if velocity.x < 0:
			acceleration *= movement_settings.direction_change_factor
		velocity.x = minf(_current_move_speed, velocity.x + acceleration * delta)
		direction.is_right = true
	else:
		velocity.x = move_toward(velocity.x, 0, movement_settings.move_deceleration * delta)

func _crouch():
	_is_crouching = true
	standing_hitbox.disabled = true
	standing_sprite.visible = false
	crouching_hitbox.disabled = false
	crouching_sprite.visible = true
	_current_move_speed = movement_settings.crouch_move_speed

func _uncrouch():
	_is_crouching = false
	standing_hitbox.disabled = false
	standing_sprite.visible = true
	crouching_hitbox.disabled = true
	crouching_sprite.visible = false
	_current_move_speed = movement_settings.move_speed

func _input(event: InputEvent) -> void:
	
	if _state == State.CONTROL:
		_normal_input(event)
	elif _state == State.UNDERGROUND:
		if event.is_action_pressed("jump"):
			standing_sprite.visible = true
			_current_move_speed = movement_settings.move_speed
			collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
			_state = State.CONTROL

func _burrow():
	_state = State.UNDERGROUND
	_uncrouch()
	_current_move_speed = movement_settings.burrow_speed
	collision_layer = Constants.INVINCIBLE_LAYER
	standing_sprite.visible = false

func _normal_input(event: InputEvent):
	if event.as_text().is_valid_int():
		var index := event.as_text().to_int() - 1
		if index < inventory.get_size() and index >= 0:
			inventory.set_held_item(index)

	if _state != State.CONTROL:
		return
	if event.is_action_pressed("shield") and is_on_floor():
		$Shield.enable()
		if inventory.get_held_item() == _weapon:
			_weapon.set_firing(null)
		_current_move_speed = movement_settings.shield_move_speed
	if event.is_action_released("shield"):
		$Shield.disable()
		_current_move_speed = movement_settings.move_speed
	if event.is_action_pressed("fire") and not $Shield.is_enabled():
		if inventory.get_held_item() == _weapon:
			_weapon.set_firing($Direction)
		else:
			use_gadget()
	if event.is_action_released("fire"):
		if inventory.get_held_item() == _weapon:
			_weapon.set_firing(null)
	if is_on_floor() and not $Shield.is_enabled():
		if event.is_action_pressed("jump") and !Input.is_action_pressed("crouch"):
			_is_jumping = true
			velocity.y = -movement_settings.jump_speed
	elif event.is_action_pressed("jump"):
		_jump_buffer = movement_settings.jump_buffer_time
	if _is_jumping and event.is_action_released("jump"):
		_is_jumping = false
		_jump_time = 0.0
	if event.is_action_pressed("roll") and _can_roll and not $Shield.is_enabled():
		_roll()
	if event.is_action_pressed("reload") and _weapon:
		if !_weapon.is_reloading:
			_weapon.reload()
	if event.is_action_pressed("interact"):
		for area in $InteractArea.get_overlapping_areas():
			for child in area.get_children():
				if child is Interactable:
					child.interact()

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
	await get_tree().create_timer(movement_settings.roll_time).timeout
	_state = State.CONTROL
	velocity.x *= 0.4
	$StandingSprite.flip_v = false
	$CrouchingSprite.flip_v = false
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
	_can_roll = false
	await get_tree().create_timer(movement_settings.roll_cooldown_time).timeout
	_can_roll = true

func _on_health_died() -> void:
	print("The player has died")

func _on_health_damage_taken(_amount: int, _direction: Vector2) -> void:
	AudioManager.play_sound(self, load("res://assets/SoundEffects/hit.wav"))
	_freeze_time()
	collision_layer = Constants.INVINCIBLE_LAYER
	_flash_invincible()
	await get_tree().create_timer(movement_settings.invincible_time).timeout
	if _state != State.UNDERGROUND:
		collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER

func is_holding_weapon() -> bool:
	return _weapon == inventory.get_held_item()

func get_current_item() -> Node2D:
	return inventory.get_held_item()

func is_on_platform():
	return $PlatformRaycast.is_colliding()

func get_platform_height():
	return $PlatformRaycast.get_collision_point().y

func _flash_invincible() -> void:
	while collision_layer == Constants.INVINCIBLE_LAYER:
		# TODO: remove when we get a player underground sprite (mound)
		if _state == State.UNDERGROUND: break
		
		standing_sprite.visible = false
		crouching_sprite.visible = false
		await get_tree().create_timer(0.05).timeout
		standing_sprite.visible = !_is_crouching
		crouching_sprite.visible = _is_crouching
		await get_tree().create_timer(0.05).timeout
	
func get_health() -> Health:
	return $Health;

func use_gadget():
	var gadget = inventory.get_held_item().instantiate()
	gadget.init(direction)
	gadget.global_position = _item_position.global_position
	get_tree().current_scene.add_child(gadget)
