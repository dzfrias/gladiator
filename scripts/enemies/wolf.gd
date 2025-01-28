class_name Wolf extends CharacterBody2D

@export var speed: float = 300.0
@export var attack_speed: float = 600.0
@export var attack_jump: float = -250.0
@export var attack_distance: float = 200.0
@export var attack_damage: float = 5.0
@export var attack_time: float = 0.6
@export var attack_windup_time: float = 0.1
@export var attack_tired_time: float = 0.8

@onready var detection_zone: Area2D = $DetectionZone

var _always_tracking: bool
var _state: State = State.IDLE
var _tracking: Node2D
var _attack_direction := 0.0

enum State {
	IDLE,
	# Detected player in zone, follow
	TRACKING,
	ATTACKING,
	# Recovering from attack (or beginning an attack)
	TIRED,
}

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
			scale.x = direction
			if abs(dist) <= attack_distance:
				_attack_direction = direction
				_attack()
			else:
				velocity.x = direction * speed
		State.IDLE:
			# TODO make wolf patrol back and forth
			if _always_tracking:
				_tracking = Player.Instance
				_state = State.TRACKING
			velocity.x = 0
		State.TIRED:
			velocity.x = 0
		State.ATTACKING:
			assert(_attack_direction != 0)
			velocity.x = _attack_direction * attack_speed

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

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		_tracking = null
		if _state == State.TRACKING:
			_state = State.IDLE

func _on_health_damage_taken(_amount: float) -> void:
	print("Wolf damage taken")

func _on_health_died() -> void:
	print("Wolf died")
	queue_free()

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(attack_damage)
