class_name Burrower extends FollowEnemy

@export var burrow_speed: float = 250.0
@export var attack_cooldown_time: float = 5.0
@export var stop_idle_mean_time: float = 0.5
@export var stop_idle_sd: float = 0.05
@export var attack_jump_y_speed: float = 200.0
@export var attack_jump_x_speed: float = 200.0

var _underground: bool
var _attack_is_cooling_down: bool
var _stop_idle_is_running: bool
@onready var _original_layer := collision_layer
@onready var _original_weapon_x: float = $Weapon.position.x
@onready var _original_speed := speed

func _physics_process(delta: float) -> void:
	super(delta)
	
	$UndergroundParticles.emitting = _underground
	if _underground:
		$AnimatedSprite2D.play("underground")
	elif not _state == State.TIRED:
		$AnimatedSprite2D.play("walk" if velocity.x != 0 else "idle")
	
	_align_with_direction()
	if _state != State.TRACKING:
		return
	if not _underground:
		_set_burrowing(true)

func _attack() -> void:
	assert(_underground)
	
	_set_burrowing(false)
	
	_state = State.ATTACKING
	velocity.y = -attack_jump_y_speed
	var xdist := _tracking.position.x - position.x
	velocity.x = signf(xdist) * attack_jump_x_speed
	await hit_floor
	assert(_state == State.ATTACKING)
	velocity.x = 0.0
	
	$Direction.scalar = signf(_tracking.position.x - position.x)
	_align_with_direction()
	while $Weapon.ammo > 0:
		await $Weapon.fire($Direction.angle)
	
	_state = State.TIRED
	await $Weapon.reload()
	assert(_state == State.TIRED)
	
	_state = State.TRACKING
	_attack_is_cooling_down = true
	await get_tree().create_timer(attack_cooldown_time).timeout
	_attack_is_cooling_down = false

func _can_attack() -> bool:
	return _underground and not _attack_is_cooling_down

func _process_stopped(_delta: float) -> void:
	if _stop_idle_is_running or not _underground:
		return
	var xdist := _tracking.position.x - position.x
	_do_stop_idle(-signf(xdist))

func _do_stop_idle(direction: float) -> void:
	assert(absf(direction) == 1)
	_stop_idle_is_running = true
	velocity.x = direction * speed
	await get_tree().create_timer(randfn(stop_idle_mean_time, stop_idle_sd)).timeout
	_stop_idle_is_running = false

func _set_burrowing(burrowing: bool) -> void:
	if burrowing:
		_state = State.TIRED
		$AnimatedSprite2D.play("burrow")
		await $AnimatedSprite2D.animation_finished
		_state = State.TRACKING
		speed = burrow_speed
		collision_layer = Constants.INVINCIBLE_LAYER
	else:
		$AnimatedSprite2D.play("idle")
		speed = _original_speed
		collision_layer = _original_layer
	_underground = burrowing

func _align_with_direction() -> void:
	$AnimatedSprite2D.flip_h = not $Direction.is_right
	$Weapon.position.x = _original_weapon_x * $Direction.scalar
