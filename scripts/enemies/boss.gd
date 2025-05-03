class_name Boss extends FollowEnemy

@export_category("Melee Attack")
@export var _melee_distance = 100
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
@export var _slam_particles: PackedScene
@export var _slam_distance = 300
@export var _slam_ripple_amount = 5
@export var _slam_ripple_distance = 200
@export var _time_between_ripples = 0.76

var _attack_state = AttackState.NONE
var attacks = [
	Attack.new(AttackState.MELEE, .4),
	Attack.new(AttackState.GROUND_SLAM, .4),
	Attack.new(AttackState.CHARGE, .2)
]

@onready var _original_attack_x = $AttackBox.position.x

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
	
	match _state:
		State.TRACKING:
			_align_with_direction()
			$AnimatedSprite2D.play("walk")
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
	$AnimatedSprite2D.flip_h = direction == 1
	$AttackBox.position.x = _original_attack_x * direction

func melee_attack():
	_state = State.TIRED
	$AnimatedSprite2D.play("melee")
	await await_attack_frame(3)
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
	$AnimatedSprite2D.play("run")
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
	$AnimatedSprite2D.play("jump")
	var _original_attack_box_pos = $AttackBox.global_position
	await await_attack_frame(8)
	_state = State.ATTACKING
	$AttackBox/CollisionShape2D.disabled = false
	for i in range(_slam_ripple_amount):
		spawn_slam_particles()
		await get_tree().create_timer(_time_between_ripples).timeout
		$AttackBox.global_position.x += _slam_ripple_distance * $Direction.scalar
	assert(_state == State.ATTACKING)
	_state = State.TIRED
	$AttackBox/CollisionShape2D.disabled = true
	$AttackBox.global_position = _original_attack_box_pos
	await get_tree().create_timer(attack_tired_time).timeout
	assert(_state == State.TIRED)
	_state = State.TRACKING

func await_attack_frame(frame):
	while true:
		if $AnimatedSprite2D.frame == frame:
			break
		await get_tree().create_timer(.1).timeout

func spawn_slam_particles():
	var slam_particles = _slam_particles.instantiate() as CPUParticles2D
	get_tree().current_scene.add_child(slam_particles)
	slam_particles.global_position = $AttackBox/ParticlePosition.global_position
	slam_particles.emitting = true
	await get_tree().create_timer(slam_particles.lifetime).timeout
	slam_particles.queue_free()
	
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
	$AnimatedSprite2D.play("idle")
	_attack_state = AttackState.NONE

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(attack_damage, Vector2($Direction.scalar, 0))
