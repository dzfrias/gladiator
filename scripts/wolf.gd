class_name Wolf extends CharacterBody2D

@export var speed: float = 300.0
@export var attack_speed: float = 600.0
@export var attack_jump: float = -250.0
@export var attack_distance: float = 200.0
@export var attack_damage: float = 5.0

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
				_state = State.TIRED
				_attack_direction = direction
				$WindupTimer.start()
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

	move_and_slide()

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		_state = State.TRACKING
		_tracking = body

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		_tracking = null

func _on_health_damage_taken(_amount: float) -> void:
	print("Wolf damage taken")

func _on_health_died() -> void:
	print("Wolf died")
	queue_free()

func _on_attack_timer_timeout() -> void:
	assert(_state == State.ATTACKING)
	_state = State.TIRED
	_attack_direction = 0.0
	$TiredTimer.start()
	$AttackBox/CollisionShape2D.disabled = true

func _on_tired_timer_timeout() -> void:
	assert(_state == State.TIRED)
	_state = State.TRACKING if _tracking else State.IDLE

func _on_windup_timer_timeout() -> void:
	# Should already be set
	assert(_attack_direction != 0 and _state == State.TIRED)
	_state = State.ATTACKING
	velocity.y = attack_jump
	$AttackTimer.start()
	$AttackBox/CollisionShape2D.disabled = false

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(attack_damage)
