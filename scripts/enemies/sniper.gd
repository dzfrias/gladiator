class_name Sniper extends CharacterBody2D

@export var move_speed: float = 50.0
@export var attack_distance: float = 1000.0
@export var notify_depth: int = 2
@export var warning_flashes: int = 10
@export_range(0.5, 8, 0.1) var prepare_attack_time: float = 1.5
@export_range(0.5, 8, 0.1) var min_move_time := 1.5
@export_range(0.5, 8, 0.1) var max_move_time := 2.5
@export_range(0.5, 8, 0.1) var min_idle_time := 2
@export_range(0.5, 8, 0.1) var max_idle_time := 3
@export_range(0.5, 8, 0.1) var initial_patrol_wait_max := 4

var _state: State = State.TIRED
@onready var _original_weapon_x: float = $Weapon.position.x

enum State {
	MOVING,
	TIRED,
	ATTACKING,
}

func _ready() -> void:
	_move()
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	match _state:
		State.MOVING:
			velocity.x = move_speed * $Direction.scalar
			# Check reaching the edge of a platform or the environment
			if (not $EdgeDetector.left.is_colliding() and velocity.x < 0) or (not $EdgeDetector.right.is_colliding() and velocity.x > 0):
				$Direction.switch()
		State.TIRED:
			velocity.x = 0.0
		State.ATTACKING:
			velocity.x = 0.0
	
	move_and_slide()
	_align_with_direction()

func _move() -> void:
	_state = State.TIRED
	await get_tree().create_timer(initial_patrol_wait_max).timeout
	
	var should_patrol_right := true
	while true:
		_state = State.MOVING
		await get_tree().create_timer(randf_range(min_move_time, max_move_time)).timeout
		
		if (Player.Instance.global_position - global_position).length() <= attack_distance:
			notify(notify_depth)
			await _shoot()
		else:
			_state = State.TIRED
			await get_tree().create_timer(randf_range(min_idle_time, max_idle_time)).timeout
		
		$Direction.is_right = should_patrol_right
		should_patrol_right = not should_patrol_right

func _shoot() -> void:
	_state = State.ATTACKING
	$Direction.scalar = signf(Player.Instance.global_position.x - global_position.x)
	$Weapon.activate_prefire_flash()
	for _i in range(warning_flashes):
		Debug.draw_line(
			$Weapon.global_position,
			Player.Instance.global_position,
			5.0,
			Color.RED,
			0.05,
		)
		await get_tree().create_timer(prepare_attack_time / warning_flashes).timeout
	$Weapon.deactivate_prefire_flash()
	
	var angle := get_angle_to(Player.Instance.global_position)
	await $Weapon.fire(angle)
	_state = State.MOVING

func notify(depth: int = 0) -> void:
	if depth == 0:
		return
	for body in $NotifyZone.get_overlapping_bodies():
		body.notify(depth - 1)

func _align_with_direction() -> void:
	$Weapon.position.x = _original_weapon_x * $Direction.scalar

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	notify(notify_depth)

func _on_health_died() -> void:
	queue_free()
