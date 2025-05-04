class_name Sniper extends Enemy

@export var move_speed: float = 50.0
@export var attack_distance: float = 1000.0
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
	super()
	got_stunned.connect(_on_got_stunned)
	_move()

func _process(delta: float) -> void:
	if not is_on_floor() and not stunned:
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
	
	move()
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
	var angle := get_angle_to(Player.Instance.global_position)
	var player_pos = Player.Instance.global_position
	
	$Direction.scalar = signf(Player.Instance.global_position.x - global_position.x)
	$Weapon.activate_prefire_flash()
	for _i in range(warning_flashes):
		if _state != State.ATTACKING:
			return
		
		var slope = player_pos - $Weapon.global_position
		var draw_pos = player_pos + slope * 100
		Debug.draw_line(
			$Weapon.global_position,
			draw_pos,
			5.0,
			Color.RED,
			0.05,
		)
		await get_tree().create_timer(prepare_attack_time / warning_flashes).timeout
	$Weapon.deactivate_prefire_flash()
	
	await $Weapon.fire(angle)
	_state = State.MOVING

func _on_got_stunned() -> void:
	_state = State.MOVING

func direction() -> Direction:
	return $Direction

func _align_with_direction() -> void:
	$Weapon.position.x = _original_weapon_x * $Direction.scalar

func _on_health_damage_taken(_amount: float, _direction: Vector2):
	super(_amount, _direction)
	AudioManager.play_sound(self, load("res://assets/SoundEffects/hit.wav"))
