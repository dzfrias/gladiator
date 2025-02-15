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

@export var melee_damage: float = 5
@export var melee_knockback: Vector2 = Vector2(1000, -500)
@export var melee_cooldown: float = 2

var _can_melee := true
# NOTE this field can be null (if the player has no weapon)
var _weapon: Weapon
var _state := State.CONTROL
var _can_roll := true
var _is_crouching := false
@onready var _combat_flip_position = $Weapon.position
var _is_jumping := false
var _jump_time := 0.0
var _jump_buffer := 0.0
@onready var _melee_box = $MeleeBox
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
			if Input.is_action_pressed("crouch"):
				if Input.is_action_pressed("jump"):
					set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
				else:
					set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
					_is_crouching = true
					scale.y = 0.5
			else:
				scale.y = 1
				_is_crouching = false
			
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
				$Direction.is_right = false
				_melee_box.position = Vector2(-_combat_flip_position.x, _combat_flip_position.y)
				_weapon.position = Vector2(-_combat_flip_position.x, _combat_flip_position.y)
			elif Input.is_action_pressed("right"):
				var acceleration := move_acceleration
				if velocity.x < 0:
					acceleration *= direction_change_factor
				if _is_crouching:
					velocity.x = minf(crouch_move_speed, velocity.x + acceleration * delta)
				else:
					velocity.x = minf(move_speed, velocity.x + acceleration * delta)
				$Direction.is_right = true
				_melee_box.position = _combat_flip_position
				_weapon.position = _combat_flip_position
			else:
				velocity.x = move_toward(velocity.x, 0, move_deceleration * delta)
		State.ROLL:
			velocity.x = roll_speed * $Direction.scalar
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if _state != State.CONTROL:
		return
	if event.is_action_pressed("fire") and _weapon:
		var hit_enemy := false
		#if _melee_box.has_overlapping_bodies() and _can_melee:
			#for body in _melee_box.get_overlapping_bodies():
				#var took_damage = false
				#for child in body.get_children():
					#if child is Health:
						#var hit_object_health = child as Health
						#hit_object_health.take_damage(melee_damage, Vector2(_direction, 0))
						#took_damage = true
						#hit_enemy = true
						#melee_timer()
				#if body is CharacterBody2D and took_damage:
					## Applies Knockback
					#var character_body = body as CharacterBody2D
					#character_body.velocity = Vector2(_direction * melee_knockback.x, melee_knockback.y) 
				#if body is Vulture:
					#var vulture = body as Vulture
					#vulture._velocity = _direction * melee_knockback
		if !hit_enemy:
			_weapon.set_firing($Direction)
	if event.is_action_released("fire") and _weapon:
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
	if event.is_action_pressed("toggle_weapon"):
		if not _weapon:
			_weapon = $Weapon
		else:
			_weapon.set_firing(null)
			_weapon = null
		weapon_changed.emit()

func melee_timer():
	_can_melee = false
	await get_tree().create_timer(melee_cooldown).timeout
	_can_melee = true

func damage(amount: float, direction: Vector2) -> void:
	if $Health.has_died:
		return
	print("Player hit")
	$Health.take_damage(amount, direction)

func _roll() -> void:
	_state = State.ROLL
	_is_jumping = false
	_jump_buffer = 0.0
	if _weapon:
		_weapon.set_firing(null)
	assert(collision_layer == Constants.PLAYER_LAYER | Constants.ENTITY_LAYER)
	collision_layer = Constants.INVINCIBLE_LAYER
	$Sprite2D.flip_v = true
	await get_tree().create_timer(roll_time).timeout
	_state = State.CONTROL
	velocity.x *= 0.4
	$Sprite2D.flip_v = false
	collision_layer = Constants.PLAYER_LAYER | Constants.ENTITY_LAYER
	_can_roll = false
	await get_tree().create_timer(roll_cooldown_time).timeout
	_can_roll = true

func _on_health_died() -> void:
	print("The player has died")

func get_weapon() -> Weapon:
	return _weapon

func is_on_platform():
	var result = _platform_raycast()
	return !result.is_empty()

func get_platform_height():
	# Assums that platform is checked already
	var result = _platform_raycast()
	return result.position.y

func _platform_raycast() -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 100))
	query.set_collision_mask(Constants.PLATFORM_LAYER)
	var result = space_state.intersect_ray(query)
	return result
	
func get_health() -> Health:
	return $Health;
