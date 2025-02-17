class_name FollowEnemy extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_height: float = -800
@export var stop_dist: float = 0.0
@export var jump_follow_cooldown: float = 0.0
@export var impact_particle_prefab: PackedScene

@onready var _platform_detection = $PlatformDetection
var _state: State = State.IDLE
var _tracking: Node2D
var _jump_follow_timer := 0.0

enum State {
	IDLE,
	TRACKING,
	ATTACKING,
	TIRED,
}

func _ready() -> void:
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)
	$DetectionZone.body_exited.connect(_on_detection_zone_body_exited)
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
			
			var above = Player.Instance.is_on_platform() and Player.Instance.get_platform_height() < global_position.y and is_on_floor() and _platform_detection.is_detecting_platform()
			if above:
				_jump_follow_timer += delta
				if _jump_follow_timer >= jump_follow_cooldown:
					velocity.y = jump_height
					_jump_follow_timer = 0.0
			
			var below = _platform_detection.is_on_platform() and (!Player.Instance.is_on_platform() or Player.Instance.get_platform_height() > _platform_detection.get_platform_height()) and Player.Instance.is_on_floor()
			if below:
				_jump_follow_timer += delta
				if _jump_follow_timer >= jump_follow_cooldown:
					set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
					_jump_follow_timer = 0.0
			else:
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
			
			if not above and not below:
				_jump_follow_timer = 0.0
			
			if abs(dist) <= stop_dist:
				if is_on_floor() and _can_attack() and velocity.y == 0.0:
					_attack()
				elif velocity.y != 0.0:
					velocity.x = direction * speed
				else:
					velocity.x = 0.0
			else:
				velocity.x = direction * speed
		State.IDLE:
			# TODO make enemy patrol back and forth
			velocity.x = 0
		State.TIRED:
			velocity.x = 0
		State.ATTACKING:
			pass
	
	move_and_slide()

func _attack() -> void:
	pass

func _can_attack() -> bool:
	return true

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if _state == State.IDLE:
			_state = State.TRACKING
		_tracking = body

func _on_detection_zone_body_exited(_body: Node2D) -> void:
	pass

func _on_health_damage_taken(_amount: float, direction: Vector2) -> void:
	var impact_particles = impact_particle_prefab.instantiate()
	impact_particles.global_position = global_position
	get_tree().current_scene.add_child(impact_particles)
	impact_particles.direction = direction
	impact_particles.emitting = true

func _on_health_died() -> void:
	queue_free()
