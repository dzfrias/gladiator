class_name FollowEnemy extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_height: float = -800
@export var stop_dist: float = 0.0
@export var jump_follow_cooldown: float = 0.0
@export var patrol_speed = 50
@export var notify_depth = 2
@export_range(0.5, 8, 0.1) var min_move_time := 1.5
@export_range(0.5, 8, 0.1) var max_move_time := 2.5
@export_range(0.5, 8, 0.1) var min_idle_time := 2
@export_range(0.5, 8, 0.1) var max_idle_time := 3
@export_range(0.5, 8, 0.1) var initial_patrol_wait_max := 4

@onready var _platform_detection = $PlatformDetection
var _state: State
var _tracking: Node2D
var _jump_follow_timer := 0.0
@onready var _original_patrol_speed = patrol_speed
var _stunned: bool

signal hit_floor
signal on_state_changed(state)

enum State {
	IDLE,
	TRACKING,
	ATTACKING,
	TIRED,
	SPAWNING,
}

func _ready() -> void:
	_patrol()
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match _state:
		State.TRACKING:
			assert(_tracking != null)
			var dist := _tracking.position.x - position.x
			var direction := signf(dist)
			$Direction.scalar = direction
			
			var is_player_above = Player.Instance.is_on_platform() and Player.Instance.get_platform_height() < global_position.y
			if is_player_above and _platform_detection.is_detecting_platform() and is_on_floor():
				_jump_follow_timer += delta
				if _jump_follow_timer >= jump_follow_cooldown:
					velocity.y = jump_height
					_jump_follow_timer = 0.0
			
			var is_player_below = (!Player.Instance.is_on_platform() or Player.Instance.get_platform_height() > _platform_detection.get_platform_height()) and Player.Instance.is_on_floor()
			if is_player_below and _platform_detection.is_on_platform():
				_jump_follow_timer += delta
				if _jump_follow_timer >= jump_follow_cooldown:
					set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
					_jump_follow_timer = 0.0
			else:
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
			
			if not is_player_above and not is_player_below:
				_jump_follow_timer = 0.0
			
			if abs(dist) <= stop_dist and !is_player_above:
				if is_on_floor() and _can_attack() and velocity.y == 0.0:
					_attack()
				elif velocity.y != 0.0:
					velocity.x = direction * speed
				else:
					_process_stopped(delta)
			else:
				velocity.x = direction * speed
		State.IDLE:
			velocity.x = patrol_speed * $Direction.scalar
			# Check reaching the edge of a platform or the environment
			if (not $EdgeDetector.left.is_colliding() and velocity.x < 0) or (not $EdgeDetector.right.is_colliding() and velocity.x > 0):
				$Direction.switch()
		State.TIRED, State.SPAWNING:
			velocity.x = 0
		State.ATTACKING:
			pass
	
	var prev_velocity := velocity
	if _stunned:
		velocity = Vector2.ZERO
	
	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		hit_floor.emit()
	
	if _stunned:
		# Restore old velocity
		velocity = prev_velocity

func notify(depth: int = 0) -> void:
	if _tracking != null:
		return
	_tracking = Player.Instance
	if _state == State.IDLE:
		_state = State.TRACKING
		on_state_changed.emit(_state)
	if depth > 0:
		for body in $NotifyZone.get_overlapping_bodies():
			body.notify(depth - 1)

func spawn_in(duration: float) -> void:
	var previous_layer := collision_layer
	collision_layer = Constants.INVINCIBLE_LAYER
	var previous_state := _state
	_state = State.SPAWNING
	on_state_changed.emit(_state)
	await get_tree().create_timer(duration).timeout
	assert(_state == State.SPAWNING)
	_state = previous_state
	on_state_changed.emit(_state)
	collision_layer = previous_layer

func _patrol() -> void:
	_state = State.IDLE
	on_state_changed.emit(_state)
	patrol_speed = 0.0
	var wait_time := randf_range(0.0, initial_patrol_wait_max)
	await get_tree().create_timer(wait_time).timeout
	patrol_speed = _original_patrol_speed
	
	while _state == State.IDLE:
		var move_time := randf_range(min_move_time, max_move_time)
		await get_tree().create_timer(move_time).timeout
		if _state != State.IDLE:
			break
		patrol_speed = 0.0
		var idle_time := randf_range(min_idle_time, max_idle_time)
		await get_tree().create_timer(idle_time).timeout
		if _state != State.IDLE:
			break
		$Direction.switch()
		patrol_speed = _original_patrol_speed
	
	patrol_speed = _original_patrol_speed

func _attack() -> void:
	pass

func _process_stopped(_delta: float) -> void:
	velocity.x = 0.0

func _can_attack() -> bool:
	return true

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		notify(notify_depth)

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	if _tracking == null:
		notify(notify_depth)
	
	_stunned = true
	await get_tree().create_timer(0.1).timeout
	_stunned = false

func _on_health_died() -> void:
	queue_free()
