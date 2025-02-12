class_name Wolf extends CharacterBody2D

@export var speed: float = 300.0
@export var attack_speed: float = 600.0
@export var attack_jump: float = -250.0
@export var attack_distance: float = 200.0
@export var attack_damage: float = 5.0
@export var attack_time: float = 0.6
@export var attack_windup_time: float = 0.1
@export var attack_tired_time: float = 0.8
@export var jump_height: float = -800
@onready var _platform_detection = $PlatformDetection

@export var impact_particle_prefab: PackedScene

var _state: State = State.IDLE
var _tracking: Node2D
var _attack_direction := 0.0
@onready var _original_attack_x = $AttackBox/CollisionShape2D.position.x

enum State {
	IDLE,
	# Detected player in zone, follow
	TRACKING,
	ATTACKING,
	# Recovering from attack (or beginning an attack)
	TIRED,
}

func track(target: Node2D) -> void:
	_tracking = target
	if _state == State.IDLE:
		_state = State.TRACKING

func _ready() -> void:
	$AttackBox.body_entered.connect(_on_attack_box_body_entered)
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
			if Player.Instance.is_on_platform() and Player.Instance.get_platform_height() < global_position.y and is_on_floor() and _platform_detection._detect_platform():
				velocity.y = jump_height
			
			if abs(dist) <= attack_distance:
				if !Player.Instance.is_on_platform() or (_platform_detection.is_on_platform() and Player.Instance.get_platform_height() == _platform_detection.get_platform_height()):
					_attack_direction = direction
					_attack()
			else:
				velocity.x = direction * speed
		State.IDLE:
			# TODO make wolf patrol back and forth
			velocity.x = 0
		State.TIRED:
			velocity.x = 0
		State.ATTACKING:
			assert(_attack_direction != 0)
			velocity.x = _attack_direction * attack_speed
	
	if velocity.x != 0:
		_flip(signf(velocity.x))
	
	move_and_slide()

func _attack() -> void:
	assert(abs(_attack_direction) == 1)
	_state = State.TIRED
	await get_tree().create_timer(attack_windup_time).timeout
	assert(_state == State.TIRED and abs(_attack_direction) == 1)
	_state = State.ATTACKING
	velocity.y = attack_jump
	$AttackBox/CollisionShape2D.disabled = false
	await get_tree().create_timer(attack_time).timeout
	assert(_state == State.ATTACKING)
	_attack_direction = 0
	_state = State.TIRED
	$AttackBox/CollisionShape2D.disabled = true
	await get_tree().create_timer(attack_tired_time).timeout
	assert(_state == State.TIRED)
	
	_state = State.TRACKING if _tracking else State.IDLE

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
	
	print("Wolf damage taken")

func _on_health_died() -> void:
	print("Wolf died")
	queue_free()

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(attack_damage, Vector2(_attack_direction, 0))

func _flip(direction: float) -> void:
	assert(absf(direction) == 1)
	$AttackBox/CollisionShape2D.position.x = _original_attack_x * direction
