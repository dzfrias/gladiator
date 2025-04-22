class_name Boss extends FollowEnemy

@export var attack_windup_time: float
@export var attack_time: float
@export var attack_tired_time: float
@export var attack_damage: float

@export var _max_charge_time: float = 2.5
@export var _charge_speed: float = 200
@export var _wall_detection: Area2D
var _is_charging = false

@export var _slam_move_speed = 3
@export var _slam_attack_time = 4

var _attack_state = AttackState.MELEE

@onready var _original_attack_x = $AttackBox/CollisionShape2D.position.x

enum AttackState {
	MELEE,
	GROUND_SLAM,
	CHARGE
}

func _ready() -> void:
	super()
	$AttackBox.body_entered.connect(_on_attack_box_body_entered)
	$ChargeBox.body_entered.connect(_on_attack_box_body_entered)
	
func _physics_process(delta: float) -> void:
	super(delta)
	_align_with_direction()
	
	match _state:
		State.ATTACKING:
			if _attack_state == AttackState.GROUND_SLAM:
				$AttackBox.global_position.x += $Direction.scalar * _slam_move_speed

func _align_with_direction() -> void:
	var direction = $Direction.scalar
	$AnimatedSprite2D.flip_h = direction != 1
	$AttackBox/CollisionShape2D.position.x = _original_attack_x * direction

func melee_attack():
	_state = State.TIRED
	await get_tree().create_timer(attack_windup_time).timeout
	_state = State.ATTACKING
	$AttackBox/CollisionShape2D.disabled = false
	await get_tree().create_timer(attack_time).timeout
	assert(_state == State.ATTACKING)
	_state = State.TIRED
	$AttackBox/CollisionShape2D.disabled = true
	await get_tree().create_timer(attack_tired_time).timeout
	assert(_state == State.TIRED)
	_state = State.TRACKING

func charge_attack():
	velocity.x = $Direction.scalar * _charge_speed
	_state = State.ATTACKING
	_is_charging = true
	$ChargeBox/CollisionShape2D.disabled = false
	await get_tree().create_timer(_max_charge_time).timeout
	$ChargeBox/CollisionShape2D.disabled = true
	_is_charging = false
	_state = State.TIRED
	await get_tree().create_timer(attack_tired_time).timeout
	_state = State.TRACKING

func slam_attack():
	_state = State.TIRED
	await get_tree().create_timer(attack_windup_time).timeout
	var _original_attack_box_pos = $AttackBox.global_position
	_state = State.ATTACKING
	$AttackBox/CollisionShape2D.disabled = false
	await get_tree().create_timer(_slam_attack_time).timeout
	assert(_state == State.ATTACKING)
	_state = State.TIRED
	$AttackBox/CollisionShape2D.disabled = true
	$AttackBox.global_position = _original_attack_box_pos
	await get_tree().create_timer(attack_tired_time).timeout
	assert(_state == State.TIRED)
	_state = State.TRACKING

func _can_attack() -> bool:
	if _is_charging:
		return false
	return true

func _attack() -> void:
	var _rand_int = randi_range(0, AttackState.size() - 1)
	_attack_state = AttackState.values()[_rand_int]
	match _attack_state:
		AttackState.MELEE:
			melee_attack()
		AttackState.CHARGE:
			charge_attack()
		AttackState.GROUND_SLAM:
			slam_attack()

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(attack_damage, Vector2($Direction.scalar, 0))
