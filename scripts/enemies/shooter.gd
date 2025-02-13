class_name Shooter extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 300.0
# TODO this might be best done with another detection zone
@export var stop_dist: float = 400.0
@export var y_cutoff: float = 70.0
@export var jump_height: float = -800
@export_category("Shooting")
@export var projectile: PackedScene
@export var projectile_speed := 800.0
@export var projectile_damage := 4.0
@export var idle_time := 0.5
@export var prepare_attack_time := 0.25
@export var shoot_cooldown_avg: float = 1.4
@export var shoot_cooldown_sd: float = 0.2

@export var impact_particle_prefab: PackedScene

@onready var _platform_detection = $PlatformDetection

var _state: State = State.IDLE
var _tracking: Node2D
var _can_attack: bool = true

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
			
			if Player.Instance.is_on_platform() and Player.Instance.get_platform_height() < global_position.y and is_on_floor() and _platform_detection._detect_platform():
				velocity.y = jump_height
			
			if !Player.Instance.is_on_platform() and _platform_detection.is_on_platform():
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, false)
			else:
				set_collision_mask_value(Math.ilog2(Constants.PLATFORM_LAYER) + 1, true)
			
			var xdist := _tracking.position.x - position.x
			var direction := signf(xdist)
			scale.x = direction
			var ydist := absf(_tracking.position.y - position.y)
			# If the y distance is too far, we will move towards
			# player so we can get on the same ground as them.
			if absf(xdist) > stop_dist or ydist > y_cutoff:
				velocity.x = direction * speed
			elif _can_attack:
				_shoot(direction)
			elif is_on_floor():
				velocity.x = 0
				# This allows enemy to attack when they move onto new platform instead of waiting for a long time
				_can_attack = true
		State.IDLE:
			velocity.x = 0
		State.SHOOTING:
			velocity.x = 0

	move_and_slide()

func _shoot(direction: float) -> void:
	_state = State.SHOOTING
	await get_tree().create_timer(prepare_attack_time).timeout
	var p := projectile.instantiate() as HorizontalProjectile
	get_tree().root.add_child(p)
	var angle: float
	if direction == 1:
		angle = 0.0
	else:
		angle = PI
	p.fire(projectile_speed, angle)
	p.damage = projectile_damage
	p.position = position
	await get_tree().create_timer(idle_time).timeout
	_state = State.TRACKING
	_can_attack = false
	var wait := randfn(shoot_cooldown_avg, shoot_cooldown_sd)
	await get_tree().create_timer(wait).timeout
	_can_attack = true

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
