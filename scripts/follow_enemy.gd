class_name FollowEnemy extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_height: float = -800
@export var stop_dist: float = 0.0
@export var jump_follow_cooldown: float = 0.0
@export var impact_particle_prefab: PackedScene
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
var _left_ray: RayCast2D
var _right_ray: RayCast2D

signal hit_floor

enum State {
	IDLE,
	TRACKING,
	ATTACKING,
	TIRED,
}

func _ready() -> void:
	_patrol()
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	
	_left_ray = _create_ray(true)
	add_child(_left_ray)
	_right_ray = _create_ray(false)
	add_child(_right_ray)

func _create_ray(left: bool) -> RayCast2D:
	var bounding_box: Rect2 = $CollisionShape2D.shape.get_rect()
	var ray := RayCast2D.new()
	ray.collision_mask = Constants.PLATFORM_LAYER | Constants.ENVIRONMENT_LAYER
	ray.target_position = Vector2(0.0, bounding_box.size.y / 2)
	ray.position.x = bounding_box.size.x / 2 + 10
	if left:
		ray.position.x *= -1
	ray.position.y += bounding_box.size.y / 2 - 10
	return ray

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
			if (not _left_ray.is_colliding() and velocity.x < 0) or (not _right_ray.is_colliding() and velocity.x > 0):
				$Direction.switch()
		State.TIRED:
			velocity.x = 0
		State.ATTACKING:
			pass
	
	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		hit_floor.emit()

func notify(depth: int = 0) -> void:
	if _tracking != null:
		return
	_tracking = Player.Instance
	if _state == State.IDLE:
		_state = State.TRACKING
	if depth > 0:
		for body in $NotifyZone.get_overlapping_bodies():
			body.notify(depth - 1)

func make_tired(duration: float) -> void:
	var previous_state := _state
	_state = State.TIRED
	await get_tree().create_timer(duration).timeout
	assert(_state == State.TIRED)
	_state = previous_state

func _patrol() -> void:
	_state = State.IDLE
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

func _on_health_damage_taken(_amount: float, direction: Vector2) -> void:
	var impact_particles = impact_particle_prefab.instantiate()
	impact_particles.global_position = global_position
	get_tree().current_scene.add_child(impact_particles)
	impact_particles.direction = direction
	impact_particles.emitting = true
	
	if _tracking == null:
		notify(notify_depth)

func _on_health_died() -> void:
	queue_free()
