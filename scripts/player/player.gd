class_name Player extends CharacterBody2D

signal on_ground_impact(impact_force: float)
signal on_weapon_switch
signal alt_weapon_set(weapon_stats)
signal passive_added(passive: Passive)
signal jumped
signal went_underground
signal exited_underground

@export var movement_settings: PlayerMovementSettings
@export var bullet_wall_delta: float = 100.0
@onready var selected_weapon: Weapon = $MainWeapon
var passives: Array[Passive] = []

var _underground_time := 0.0
var _state := State.CONTROL
var _can_roll := true
var _is_jumping := false
var _jump_time := 0.0
var _jump_buffer := 0.0
var _wants_burrow := false
var _is_invincible := false
var _firing: FiringWeapon = FiringWeapon.NONE
@onready var _jumps_left := movement_settings.njumps
@onready var _current_move_speed = movement_settings.move_speed
@onready var _original_item_x = $ItemPosition.position.x

static var Instance: Player

enum FiringWeapon {
	SELECTED,
	OTHER,
	NONE,
}

enum State {
	CONTROL,
	SHIELD,
	ROLL,
	UNDERGROUND
}

const WEAPON_INDICATOR = "!!WEAPON!!"

func _ready() -> void:
	movement_settings.changed.connect(_on_movement_changed)
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	if Instance != null:
		Instance.free()
		Instance = null
	Instance = self
	$MainWeapon.fired.connect(_on_weapon_fired.bind($MainWeapon))
	$AltWeapon.fired.connect(_on_weapon_fired.bind($AltWeapon))

func _process(delta: float) -> void:
	if Engine.time_scale == 0: return
	
	if _is_jumping:
		velocity.y -= movement_settings.jump_accel * delta
		_jump_time += delta
		if _jump_time >= movement_settings.jump_hold_time:
			_is_jumping = false
	elif not is_on_floor():
		var factor := movement_settings.gravity_scale if not is_in_fallthrough() else movement_settings.fast_fall_gravity_scale
		velocity.y += get_gravity().y * factor * delta
	
	# This gives the player a small window to press the jump button before they hit the ground
	if _jump_buffer > 0:
		_jump_buffer = max(0, _jump_buffer - delta)
		if _state == State.CONTROL and is_on_floor():
			_jump()
		if is_underground():
			_jump()
			_unburrow()
	if not _is_jumping:
		_jump_time = 0.0
	
	# As a last-ditch sanity check, disable the weapon if we're not in the control state
	if _state != State.CONTROL:
		_firing = FiringWeapon.NONE
	
	# Handle continuous (horizontal) movement
	match _state:
		State.CONTROL:
			_underground_time = maxf(_underground_time - delta * movement_settings.burrow_decrement_factor, 0.0)
			_apply_horizontal_input(delta)
			
			if is_on_floor() and not _is_jumping:
				if abs(velocity.x) > 0:
					$AnimatedSprite2D.play("walk")
					if !$WalkingAudioPlayer.playing:
						$WalkingAudioPlayer.play()
				elif $AnimatedSprite2D.get_animation() != "fire":
					$AnimatedSprite2D.play("idle")
			
			if _wants_burrow and is_on_floor():
				_burrow()
				_wants_burrow = false
		State.SHIELD:
			_underground_time = maxf(_underground_time - delta * movement_settings.burrow_decrement_factor, 0.0)
			_apply_horizontal_input(delta)
		State.UNDERGROUND:
			_underground_time += delta * movement_settings.burrow_increment_factor
			if !$DiggingAudioPlayer.playing:
				$DiggingAudioPlayer.play()
			_apply_horizontal_input(delta)
			if _underground_time >= movement_settings.max_burrow_time:
				_unburrow()
		State.ROLL:
			_underground_time = maxf(_underground_time - delta * movement_settings.burrow_decrement_factor, 0.0)
			velocity.x = movement_settings.roll_speed * $Direction.scalar
	
	# Switch direction based on mouse if using omnidirectionally-aiming weapon
	if selected_weapon.weapon_stats.aim_mode == WeaponStats.AimMode.OMNIDIRECTIONAL:
		var mouse_v := Vector2.RIGHT.rotated(get_firing_angle())
		$Direction.is_right = mouse_v.x > 0
		Debug.draw_line(
			selected_weapon.global_position,
			selected_weapon.global_position + mouse_v * 100,
			5.0,
			Color.RED,
			0.01,
		)
	
	# Fire gun if possible
	match _firing:
		FiringWeapon.NONE:
			if $MainWeapon.is_continuous():
				$MainWeapon.stop_continuous_fire()
			if alt_weapon() != null and alt_weapon().is_continuous():
				$AltWeapon.stop_continuous_fire()
		FiringWeapon.SELECTED:
			if selected_weapon.can_fire:
				if selected_weapon.is_continuous():
					selected_weapon.continuous_fire($Direction)
				else:
					selected_weapon.fire(get_firing_angle())
		FiringWeapon.OTHER:
			var other := $AltWeapon
			if selected_weapon == $AltWeapon:
				other = $MainWeapon
			if other.can_fire:
				if other.is_continuous():
					other.continuous_fire($Direction)
				else:
					other.fire(get_firing_angle())
	_align()
	_adjust_bullet_walls()
	
	# This will store our previous y-velocity, which is used to get the speed of impact if we hit
	# the ground after move_and_slide is called. We use that information for on_ground_impact
	var prev_y := velocity.y
	move_and_slide()
	
	if is_on_floor() and prev_y > 0:
		_jumps_left = movement_settings.njumps
		on_ground_impact.emit(prev_y)

func _align() -> void:
	$ItemPosition.position = Vector2(_original_item_x * $Direction.scalar, $ItemPosition.position.y)
	$MainWeapon.position = $ItemPosition.position
	$AltWeapon.position = $ItemPosition.position
	$AnimatedSprite2D.flip_h = not $Direction.is_right

func _adjust_bullet_walls() -> void:
	var camera_size = get_viewport_rect().size / $Camera2D.zoom
	var left: float = global_position.x - (camera_size.x / 2)
	var right: float = global_position.x + (camera_size.x / 2)
	$BulletWall/BulletWallLeft.global_position.x = left - bullet_wall_delta
	$BulletWall/BulletWallRight.global_position.x = right + bullet_wall_delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fallthrough"):
		set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
	if event.is_action_released("fallthrough"):
		set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
	
	if event.is_action_pressed("toggle_alt") and alt_weapon() != null:
		if selected_weapon == $MainWeapon:
			$MainWeapon.deactivate_effects()
			selected_weapon = $AltWeapon
		else:
			assert(selected_weapon == $AltWeapon)
			$AltWeapon.deactivate_effects()
			selected_weapon = $MainWeapon
		selected_weapon.activate_effects()
		on_weapon_switch.emit()
	
	match _state:
		State.CONTROL:
			# Jump
			if event.is_action_pressed("jump"):
				if not is_on_floor() and _jumps_left > 0 and _jumps_left != movement_settings.njumps:
					_jump()
				else:
					_jump_buffer = movement_settings.jump_buffer_time
			if event.is_action_released("jump"):
				_is_jumping = false
			
			# Shield
			if event.is_action_pressed("shield"):
				$Shield.enable()
				_state = State.SHIELD
				_firing = FiringWeapon.NONE
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
				_firing = FiringWeapon.SELECTED
			
			if event.is_action_pressed("use_gadget"):
				$Gadget.use()
			
			if event.is_action_released("fire"):
				_firing = FiringWeapon.NONE
			
			if event.is_action_pressed("fire_alt") and alt_weapon() != null:
				_firing = FiringWeapon.OTHER
			if event.is_action_released("fire_alt"):
				_firing = FiringWeapon.NONE
			
			# Interact
			if event.is_action_pressed("interact"):
				for area in $InteractArea.get_overlapping_areas():
					if area is Interactable:
						area.interact()
		
		State.UNDERGROUND:
			if event.is_action_released("burrow"):
				_unburrow()
			if event.is_action_pressed("jump"):
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
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("jump")
	AudioManager.play_sound(self, load("res://assets/SoundEffects/jump.wav"), -4)
	jumped.emit()
	_is_jumping = true
	_jumps_left -= 1
	velocity.y = -movement_settings.jump_speed

func damage(amount: float, direction_: Vector2) -> void:
	if $Health.has_died or collision_layer == Constants.INVINCIBLE_LAYER:
		return
	print("Player hit")
	$Health.take_damage(amount, direction_)

func _roll() -> void:
	_state = State.ROLL
	_is_jumping = false
	_jump_buffer = 0.0
	collision_layer = Constants.INVINCIBLE_LAYER
	$CrouchingSprite.flip_v = true
	await get_tree().create_timer(movement_settings.roll_time).timeout
	_state = State.CONTROL
	velocity.x *= 0.4
	$CrouchingSprite.flip_v = false
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
	_can_roll = false
	await get_tree().create_timer(movement_settings.roll_cooldown_time).timeout
	_can_roll = true

func set_alt_weapon(stats: WeaponStats) -> void:
	if stats == null:
		return
	if $AltWeapon.effects != null:
		$AltWeapon.deactivate_effects()
	$AltWeapon.weapon_stats = stats
	if selected_weapon == $AltWeapon:
		$AltWeapon.activate_effects()
		on_weapon_switch.emit()
	alt_weapon_set.emit(stats)

func gadget() -> Gadget:
	return $Gadget

func _burrow() -> void:
	assert(_state != State.UNDERGROUND)
	_state = State.UNDERGROUND
	_current_move_speed = movement_settings.burrow_speed
	$PlayerGun.visible = false
	$AnimatedSprite2D.play("burrow")
	var right := Input.is_action_pressed("right")
	var left := Input.is_action_pressed("left")
	# Equivalent to logical exclusive-or; do not give a spped boost if they're not pressing left
	# or right.
	if left != right:
		var k := 1.0 if right else -1.0
		velocity.x = maxf(absf(velocity.x), movement_settings.burrow_speed_boost) * k
	collision_layer = Constants.INVINCIBLE_LAYER
	went_underground.emit()

func _unburrow() -> void:
	assert(_state == State.UNDERGROUND)
	_state = State.CONTROL
	_current_move_speed = movement_settings.move_speed
	$AnimatedSprite2D.visible = true
	$PlayerGun.visible = true
	$DiggingAudioPlayer.stop()
	if not _is_invincible:
		collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
	exited_underground.emit()

func _on_health_died() -> void:
	print("The player has died")

func _on_health_damage_taken(_amount: int, _direction: Vector2) -> void:
	AudioManager.play_sound(self, load("res://assets/SoundEffects/hit.wav"))
	collision_layer = Constants.INVINCIBLE_LAYER
	_is_invincible = false
	_freeze_time()
	_flash_invincible()
	await get_tree().create_timer(movement_settings.invincible_time).timeout
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
	_is_invincible = false

func _freeze_time():
	get_tree().paused = true
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	# Fixes bug where player could fire indefinitely if they released "fire" or "fire_alt" during
	# time freeze.
	if not Input.is_action_pressed("fire") and not Input.is_action_pressed("fire_alt"):
		_firing = FiringWeapon.NONE
	if not Input.is_action_pressed("fallthrough"):
		set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)

func is_on_platform():
	return $PlatformRaycast.is_colliding()

func is_underground():
	return _state == State.UNDERGROUND

func get_platform_height():
	return $PlatformRaycast.get_collision_point().y

func weapon() -> Weapon:
	return selected_weapon

func alt_weapon() -> Weapon:
	if $AltWeapon.weapon_stats == null:
		return null
	return $AltWeapon

func alt_weapon_node() -> Weapon:
	return $AltWeapon

func main_weapon() -> Weapon:
	return $MainWeapon

func burrow_percentage() -> float:
	return _underground_time / movement_settings.max_burrow_time

func camera() -> PlayerCamera:
	return $Camera2D

func hitbox() -> CollisionShape2D:
	return $Hitbox

func direction() -> Direction:
	return $Direction

func sprite() -> AnimatedSprite2D:
	return $AnimatedSprite2D

func get_firing_angle() -> float:
	if selected_weapon.weapon_stats.aim_mode == WeaponStats.AimMode.OMNIDIRECTIONAL:
		return selected_weapon.get_angle_to(get_global_mouse_position())
	return $Direction.angle

func add_passive(passive: Passive) -> void:
	passives.append(passive)
	var instance := passive.scene.instantiate()
	$Passives.add_child(instance)
	passive_added.emit(passive)

func is_in_fallthrough() -> bool:
	return not get_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1)

func _on_weapon_fired(_projectile: Node2D, weapon_: Weapon) -> void:
	var strength: Vector2 = Vector2(12.0 * -$Direction.scalar, -4.0) * weapon_.weapon_stats.strength
	$Camera2D.move(strength)
	if $AnimatedSprite2D.get_animation() == "idle" or $AnimatedSprite2D.get_animation() == "fire":
		$AnimatedSprite2D.play("fire")

func _flash_invincible() -> void:
	while collision_layer == Constants.INVINCIBLE_LAYER:
		$AnimatedSprite2D.visible = false
		await get_tree().create_timer(0.05).timeout
		$AnimatedSprite2D.visible = true
		await get_tree().create_timer(0.05).timeout

func _on_movement_changed() -> void:
	if is_underground():
		_current_move_speed = movement_settings.burrow_move_speed
	else:
		_current_move_speed = movement_settings.move_speed

func get_health() -> Health:
	return $Health;
