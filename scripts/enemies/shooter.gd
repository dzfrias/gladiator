class_name Shooter extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 100.0
# TODO this might be best done with another detection zone
@export var stop_dist: float = 1200.0
@export var y_cutoff: float = 70.0
@export var jump_height: float = -800
@export var y_axis_follow_time: float = 1.0

@export var impact_particle_prefab: PackedScene

@onready var _platform_detection = $PlatformDetection

var _state: State = State.IDLE
var _tracking: Node2D
var _player_follow_time: float = 0.0

enum State {
	IDLE,
	TRACKING,
	SHOOTING,
}

func _ready() -> void:
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)
	$DetectionZone.body_exited.connect(_on_detection_zone_body_exited)
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)

func track(target: Node2D) -> void:
	_tracking = target
	if _state == State.IDLE:
		_state = State.TRACKING

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match _state:
		State.TRACKING:
			assert(_tracking != null)
			
			var above = Player.Instance.is_on_platform() and Player.Instance.get_platform_height() < global_position.y and is_on_floor() and _platform_detection.is_detecting_platform()
			if above:
				_player_follow_time += delta
				if _player_follow_time >= y_axis_follow_time:
					velocity.y = jump_height
					_player_follow_time = 0.0
			
			var below = _platform_detection.is_on_platform() and (!Player.Instance.is_on_platform() or Player.Instance.get_platform_height() > _platform_detection.get_platform_height()) and Player.Instance.is_on_floor()
			if below:
				_player_follow_time += delta
				if _player_follow_time >= y_axis_follow_time:
					set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
					_player_follow_time = 0.0
			else:
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
			
			if not above and not below:
				_player_follow_time = 0.0
			
			var xdist := _tracking.position.x - position.x
			$Direction.scalar = signf(xdist)
			scale.x = $Direction.scalar
			var ydist := absf(_tracking.position.y - position.y)
			# If the y distance is too far, we will move towards
			# player so we can get on the same ground as them.
			if absf(xdist) > stop_dist or ydist > y_cutoff:
				velocity.x = $Direction.scalar * speed
			elif !$Weapon.is_reloading:
				_shoot()
			else:
				velocity.x = 0
		State.IDLE:
			velocity.x = 0
		State.SHOOTING:
			velocity.x = 0

	move_and_slide()

func _shoot() -> void:
	_state = State.SHOOTING
	while $Weapon.ammo > 0:
		await $Weapon.fire($Direction)
	
	_state = State.TRACKING
	await $Weapon.reload()

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if _state == State.IDLE:
			_state = State.TRACKING
		_tracking = body

func _on_detection_zone_body_exited(_body: Node2D) -> void:
	pass

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	var impact_particles = impact_particle_prefab.instantiate()
	impact_particles.global_position = global_position
	get_tree().root.add_child(impact_particles)
	impact_particles.direction = _direction
	impact_particles.emitting = true
	
	print("Shooter damage taken")

func _on_health_died() -> void:
	print("Shooter died")
	queue_free()
