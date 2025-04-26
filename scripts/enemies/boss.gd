class_name Boss extends FollowEnemy

@export_category("Melee Attack")
@export var _melee_distance = 100
@export var attack_windup_time: float
@export var attack_time: float
@export var attack_tired_time: float
@export var attack_damage: float

@export_category("Charge Attack")
@export var _charge_distance = 500
@export var _max_charge_time: float = 2.5
@export var _charge_speed: float = 300
@export var _wall_detection: Area2D
var _is_charging = false

@export_category("Slam Attack")
@export var _slam_move_speed = 3
@export var _slam_attack_time = 4
@export var _slam_distance = 300

var _attack_state = AttackState.NONE
var attacks = [
	Attack.new(AttackState.MELEE, 0.7),
	Attack.new(AttackState.GROUND_SLAM, 0.2),
	Attack.new(AttackState.CHARGE, 0.1)
]

@onready var _original_attack_x = $AttackBox/CollisionShape2D.position.x

enum AttackState {
	NONE,
	MELEE,
	GROUND_SLAM,
	CHARGE
}

class Attack:
	var state
	var chance
	
	func _init(state, chance) -> void:
		self.state = state
		self.chance = chance
		assert(chance >= 0 and chance <= 1)

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
		State.TRACKING:
			if _attack_state == AttackState.NONE:
				choose_random_attack()
					
				if _attack_state == AttackState.MELEE:
					_current_stop_dist = _melee_distance
				elif _attack_state == AttackState.GROUND_SLAM:
					_current_stop_dist = _slam_distance
				else:
					_current_stop_dist = _charge_distance

func choose_random_attack():
	var random_num = randf_range(0, 1)
	var total = 0
	for attack in attacks:
		if random_num > total and random_num <= total + attack.chance:
			_attack_state = attack.state
			break
		total += attack.chance

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
	assert(_state == State.TIRED)
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
	match _attack_state:
		AttackState.MELEE:
			print("Melee")
			await melee_attack()
		AttackState.CHARGE:
			print("Charge")
			await charge_attack()
		AttackState.GROUND_SLAM:
			print("Slam")
			await slam_attack()
	_attack_state = AttackState.NONE

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(attack_damage, Vector2($Direction.scalar, 0))
