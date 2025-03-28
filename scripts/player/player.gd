class_name Player extends CharacterBody2D

signal on_ground_impact(impact_force: float)
signal on_weapon_switch

@export var movement_settings: Resource
@export var main_weapon: WeaponStats = preload("res://resources/pistol.tres")
@export var alt_weapon: WeaponStats

var _underground_time := 0.0
var _state := State.CONTROL
var _can_roll := true
var _is_jumping := false
var _jump_time := 0.0
var _jump_buffer := 0.0
var _wants_burrow := false
@onready var _current_move_speed = movement_settings.move_speed
@onready var _original_shield_x = $Shield.position.x
@onready var _original_item_x = $ItemPosition.position.x
@onready var _original_particles_x = $WalkingParticles.position.x

static var Instance

enum State {
	CONTROL,
	SHIELD,
	ROLL,
	UNDERGROUND
}

const WEAPON_INDICATOR = "!!WEAPON!!"

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	$Inventory.on_item_switched.connect(_on_item_switched)
	if Instance != null:
		Instance.free()
		Instance = null
	Instance = self
	$Weapon.weapon_stats = main_weapon
	$Inventory.add_item(WEAPON_INDICATOR)

func _process(delta: float) -> void:
	if _is_jumping:
		velocity.y -= movement_settings.jump_accel * delta
		_jump_time += delta
		if _jump_time >= movement_settings.jump_hold_time:
			_is_jumping = false
	elif not is_on_floor():
		velocity.y += get_gravity().y * movement_settings.gravity_scale * delta
	
	# This gives the player a small window to press the jump button before they hit the ground
	if _jump_buffer > 0:
		_jump_buffer = max(0, _jump_buffer - delta)
		if _state == State.CONTROL and is_on_floor():
			_jump()
	if not _is_jumping:
		_jump_time = 0.0
	
	# As a last-ditch sanity check, disable the weapon if we're not in the control state
	if _state != State.CONTROL:
		$Weapon.set_firing(null)
	
	# Handle continuous (horizontal) movement
	match _state:
		State.CONTROL:
			_underground_time = maxf(_underground_time - delta * movement_settings.burrow_decrement_factor, 0.0)
			_apply_horizontal_input(delta)
			if _wants_burrow and is_on_floor():
				_burrow()
				_wants_burrow = false
		State.SHIELD:
			_underground_time = maxf(_underground_time - delta * movement_settings.burrow_decrement_factor, 0.0)
			_apply_horizontal_input(delta)
		State.UNDERGROUND:
			_underground_time += delta * movement_settings.burrow_increment_factor
			_apply_horizontal_input(delta)
			if _underground_time >= movement_settings.max_burrow_time:
				_unburrow()
		State.ROLL:
			_underground_time = maxf(_underground_time - delta * movement_settings.burrow_decrement_factor, 0.0)
			velocity.x = movement_settings.roll_speed * $Direction.scalar
	
	# Handle walking particles
	if abs(velocity.x) > 0 and is_on_floor():
		$WalkingParticles.emitting = true
	else:
		$WalkingParticles.emitting = false
	
	_align()
	
	# This will store our previous y-velocity, which is used to get the speed of impact if we hit
	# the ground after move_and_slide is called. We use that information for on_ground_impact
	var prev_y := velocity.y
	move_and_slide()
	
	if is_on_floor() and prev_y > 0:
		on_ground_impact.emit(prev_y)

func _align() -> void:
	$ItemPosition.position = Vector2(_original_item_x * $Direction.scalar, $ItemPosition.position.y)
	$Shield.position = Vector2(_original_shield_x * $Direction.scalar, $Shield.position.y)
	$Weapon.position = $ItemPosition.position
	$WalkingParticles.position = Vector2(_original_particles_x * $Direction.scalar, $WalkingParticles.position.y)
	$WalkingParticles.direction.x = $Direction.scalar

func _input(event: InputEvent) -> void:
	if event.as_text().is_valid_int():
		var index := event.as_text().to_int() - 1
		if index < $Inventory.items.size() and index >= 0:
			$Inventory.set_held_item(index)
	
	if event.is_action_pressed("fallthrough"):
		set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
	if event.is_action_released("fallthrough"):
		set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
	
	if event.is_action_pressed("toggle_alt") and alt_weapon != null:
		if $Weapon.weapon_stats == main_weapon:
			$Weapon.weapon_stats = alt_weapon
		else:
			assert($Weapon.weapon_stats == alt_weapon)
			$Weapon.weapon_stats = main_weapon
		on_weapon_switch.emit()
	
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
			
			# Burrow
			if event.is_action_pressed("burrow"):
				if is_on_floor():
					_burrow()
				else:
					_wants_burrow = true
			if event.is_action_released("burrow"):
				_wants_burrow = false
			
			# Roll
			if event.is_action_pressed("roll"):
				_roll()
			
			# Fire
			if event.is_action_pressed("fire"):
				var item = $Inventory.get_held_item()
				if item == WEAPON_INDICATOR:
					$Weapon.set_firing($Direction)
				else:
					assert(item is GadgetInfo)
					_use_gadget(item)
			if event.is_action_released("fire"):
				$Weapon.set_firing(null)
			
			# Interact
			if event.is_action_pressed("interact"):
				for area in $InteractArea.get_overlapping_areas():
					for child in area.get_children():
						if child is Interactable:
							child.interact()
		
		State.UNDERGROUND:
			if event.is_action_released("burrow"):
				_unburrow()
			if event.is_action_pressed("jump"):
				_unburrow()
				_jump_buffer = movement_settings.jump_buffer_time
		
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
		velocity.x = move_toward(velocity.x, 0, movement_settings.move_deceleration * delta)
		return
	
	$Direction.is_right = right
	var acceleration: float = movement_settings.move_acceleration
	if left:
		if velocity.x > 0:
			acceleration *= movement_settings.direction_change_factor
		velocity.x = move_toward(velocity.x, -_current_move_speed, acceleration * delta)
	if right:
		if velocity.x < 0:
			acceleration *= movement_settings.direction_change_factor
		velocity.x = move_toward(velocity.x, _current_move_speed, acceleration * delta)

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

func _burrow() -> void:
	assert(_state != State.UNDERGROUND)
	_state = State.UNDERGROUND
	_current_move_speed = movement_settings.burrow_speed
	var right := Input.is_action_pressed("right")
	var left := Input.is_action_pressed("left")
	# Equivalent to logical exclusive-or; do not give a spped boost if they're not pressing left
	# or right.
	if left != right:
		velocity.x = movement_settings.burrow_speed_boost * $Direction.scalar
	$StandingSprite.visible = false
	collision_layer = Constants.INVINCIBLE_LAYER

func _unburrow() -> void:
	assert(_state == State.UNDERGROUND)
	_state = State.CONTROL
	_current_move_speed = movement_settings.move_speed
	$StandingSprite.visible = true
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER

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

func _on_item_switched(_current_item):
	$Weapon.set_firing(null)

func is_on_platform():
	return $PlatformRaycast.is_colliding()

func is_underground():
	return _state == State.UNDERGROUND

func get_platform_height():
	return $PlatformRaycast.get_collision_point().y

func inventory() -> Inventory:
	return $Inventory

func weapon() -> Weapon:
	return $Weapon

func burrow_percentage() -> float:
	return _underground_time / movement_settings.max_burrow_time

func _flash_invincible() -> void:
	while collision_layer == Constants.INVINCIBLE_LAYER:
		$StandingSprite.visible = false
		await get_tree().create_timer(0.05).timeout
		$StandingSprite.visible = true
		await get_tree().create_timer(0.05).timeout
	
func get_health() -> Health:
	return $Health;

func _use_gadget(info: GadgetInfo):
	var gadget = info.scene.instantiate()
	gadget.init($Direction)
	gadget.global_position = $ItemPosition.global_position
	get_tree().current_scene.add_child(gadget)
