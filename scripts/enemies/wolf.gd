class_name Wolf extends FollowEnemy

@export var attack_speed: float = 600.0
@export var attack_jump: float = -250.0
@export var attack_damage: float = 5.0
@export var attack_time: float = 0.6
@export var attack_windup_time: float = 0.1
@export var attack_tired_time: float = 0.8

@onready var _original_attack_x = $AttackBox/CollisionShape2D.position.x

func _ready() -> void:
	super()
	$AttackBox.body_entered.connect(_on_attack_box_body_entered)
	got_stunned.connect(_on_got_stunned)

func _physics_process(delta: float) -> void:
	super(delta)
	_align_with_direction()

	if velocity.x == 0:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("move")

func _attack() -> void:
	_state = State.TIRED
	await get_tree().create_timer(attack_windup_time).timeout
	_state = State.ATTACKING
	velocity.y = attack_jump
	$AttackBox/CollisionShape2D.disabled = false
	velocity.x = $Direction.scalar * attack_speed
	await get_tree().create_timer(attack_time).timeout
	assert(_state == State.ATTACKING)
	_state = State.TIRED
	$AttackBox/CollisionShape2D.disabled = true
	await get_tree().create_timer(attack_tired_time).timeout
	assert(_state == State.TIRED)
	_state = State.TRACKING

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player := body as Player
	player.damage(attack_damage, Vector2($Direction.scalar, 0))

func _align_with_direction() -> void:
	var direction = $Direction.scalar
	$AnimatedSprite2D.flip_h = direction != 1
	$AttackBox/CollisionShape2D.position.x = _original_attack_x * direction

func _on_got_stunned() -> void:
	$AttackBox/CollisionShape2D.disabled = true
