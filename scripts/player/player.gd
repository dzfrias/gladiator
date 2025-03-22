class_name Player extends CharacterBody2D

signal on_ground_impact(impact_force: float)

@export var movement_settings: Resource

var _state := State.CONTROL
var _can_roll := true
var _is_jumping := false
var _jump_time := 0.0
var _jump_buffer := 0.0
@onready var _current_move_speed = movement_settings.move_speed
@onready var _original_shield_x = $Shield.position.x
@onready var _original_item_x = $ItemPosition.position.x

static var Instance

enum State {
	CONTROL,
	SHIELD,
	ROLL,
	UNDERGROUND
}

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	$Inventory.on_item_switched.connect(_on_item_switched)
	if Instance != null:
		Instance.free()
		Instance = null
	Instance = self

func _process(delta: float) -> void:
	if _is_jumping:
		velocity.y -= movement_settings.jump_accel * delta
		_jump_time += delta
		if _jump_time >= movement_settings.jump_hold_time:
			_is_jumping = false
	elif not is_on_floor():
		velocity.y += get_gravity().y * movement_settings.gravity_scale * delta
	if _jump_buffer > 0:
		_jump_buffer = max(0, _jump_buffer - delta)
		if _state == State.CONTROL and is_on_floor():
			_jump()
	if not _is_jumping:
		_jump_time = 0.0
	
	if _state != State.CONTROL:
		$Weapon.set_firing(null)
	match _state:
		State.CONTROL, State.SHIELD, State.UNDERGROUND:
			_apply_horizontal_input(delta)
		State.ROLL:
			velocity.x = movement_settings.roll_speed * $Direction.scalar
	
	_align()
	move_and_slide()

func _align() -> void:
	$ItemPosition.position = Vector2(_original_item_x * $Direction.scalar, $ItemPosition.position.y)
	$Shield.position = Vector2(_original_shield_x * $Direction.scalar, $Shield.position.y)
	$Weapon.position = $ItemPosition.position

func _input(event: InputEvent) -> void:
	match _state:
		State.CONTROL:
			# Jump
			if event.is_action_pressed("jump"):
				_jump_buffer = movement_settings.jump_buffer_time
			if event.is_action_released("jump"):
				_is_jumping = false
			
			# Shield
			if event.is_action_pressed("shield"):
				$Shield.enable()
				_state = State.SHIELD
				$Weapon.set_firing(null)
				_current_move_speed = movement_settings.shield_move_speed
			
			# There are two scenarios when the crouch button is pressed:
			# 1. On the floor to start a burrow
			# 2. On platform to fall through it
			if event.is_action_pressed("crouch"):
				if is_on_floor() and not is_on_platform():
					_state = State.UNDERGROUND
					_current_move_speed = movement_settings.burrow_speed
					$StandingSprite.visible = false
					collision_layer = Constants.INVINCIBLE_LAYER
				else:
					set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
			# If the crouch button is released while in the control state, we used it to fall
			# through a platform, so we should re-enable the platform layer
			if event.is_action_released("crouch"):
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
			
			# Roll
			if event.is_action_pressed("roll"):
				_roll()
			
			# Fire
			if event.is_action_pressed("fire"):
				if $Inventory.get_held_item() is WeaponStats:
					$Weapon.set_firing($Direction)
				elif $Inventory.get_held_item() != null:
					_use_gadget()
			if event.is_action_released("fire"):
				$Weapon.set_firing(null)
			
			# Interact
			if event.is_action_pressed("interact"):
				for area in $InteractArea.get_overlapping_areas():
					for child in area.get_children():
						if child is Interactable:
							child.interact()
		
		State.UNDERGROUND:
			if event.is_action_released("crouch"):
				_state = State.CONTROL
				_current_move_speed = movement_settings.move_speed
				$StandingSprite.visible = true
				collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
		
		State.SHIELD:
			if event.is_action_released("shield"):
				$Shield.disable()
				_state = State.CONTROL
				_current_move_speed = movement_settings.move_speed

func _apply_horizontal_input(delta: float) -> void:
	var left := Input.is_action_pressed("left")
	var right := Input.is_action_pressed("right")

	# Slow the player down in two scenarios:
	# 1. Both left and right and being pressed
	# 2. Neither left nor right are being pressed
	if (left and right) or not (left or right):
		velocity.x = move_toward(velocity.x, 0, movement_settings.move_acceleration * delta)
		return
	
	$Direction.is_right = right
	var acceleration: float = movement_settings.move_acceleration
	if left:
		if velocity.x > 0:
			acceleration *= movement_settings.direction_change_factor
		velocity.x = maxf(-_current_move_speed, velocity.x - acceleration * delta)
	if right:
		if velocity.x < 0:
			acceleration *= movement_settings.direction_change_factor
		velocity.x = minf(_current_move_speed, velocity.x + acceleration * delta)

func _jump() -> void:
	_is_jumping = true
	velocity.y = -movement_settings.jump_speed

func damage(amount: float, direction: Vector2) -> void:
	if $Health.has_died or collision_layer == Constants.INVINCIBLE_LAYER:
		return
	print("Player hit")
	$Health.take_damage(amount, direction)

func _roll() -> void:
	_state = State.ROLL
	_is_jumping = false
	_jump_buffer = 0.0
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
	collision_layer = Constants.INVINCIBLE_LAYER
	_freeze_time()
	_flash_invincible()
	await get_tree().create_timer(movement_settings.invincible_time).timeout
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER

func _freeze_time():
	get_tree().paused = true
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false

func is_holding_weapon() -> bool:
	return $Inventory.get_held_item() is WeaponStats

func _on_item_switched(current_item):
	$Weapon.set_firing(null)
	if current_item is WeaponStats:
		$Weapon.weapon_stats = current_item

func is_on_platform():
	return $PlatformRaycast.is_colliding()

func get_platform_height():
	return $PlatformRaycast.get_collision_point().y

func inventory() -> Inventory:
	return $Inventory

func weapon() -> Weapon:
	return $Weapon

func _flash_invincible() -> void:
	while collision_layer == Constants.INVINCIBLE_LAYER:
		$StandingSprite.visible = false
		await get_tree().create_timer(0.05).timeout
		$StandingSprite.visible = true
		await get_tree().create_timer(0.05).timeout
	
func get_health() -> Health:
	return $Health;

func _use_gadget():
	var gadget = $Inventory.get_held_item().instantiate()
	gadget.init($Direction)
	gadget.global_position = $ItemPosition.global_position
	get_tree().current_scene.add_child(gadget)
