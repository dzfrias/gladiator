class_name Vulture extends Area2D

@export var x_speed := 200.0
@export var y_speed := 100.0
@export var stop_dist := 150.0
@export var fly_height := 300.0
@export var attack_idle_time := 1.0
@export var attack_windup_time := 0.3
@export var attack_cooldown_time := 2.0
@export var projectile: PackedScene
@export var projectile_speed := 500.0

var _state := State.IDLE
var _tracking: Node2D
var _idle_time := 0.0
var _can_attack := true
const _GROUND_RAYCAST_DISTANCE = 10000.0

enum State {
	IDLE,
	TRACKING,
	ATTACK_WINDUP,
}

func _ready() -> void:
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)
	$DetectionZone.body_exited.connect(_on_detection_zone_body_exited)
	$Health.damage_taken.connect(_on_health_damage_taken)
	$Health.died.connect(_on_health_died)

func _process(delta: float) -> void:
	var ground_y := _get_ground_y()
	if abs((ground_y - fly_height) - position.y) > Constants.EPSILON:
		position.y = move_toward(position.y, ground_y - fly_height, y_speed * delta)
		_idle_time = 0.0
	
	match _state:
		State.IDLE:
			# TODO patrol
			pass
		State.TRACKING:
			assert(_tracking != null)
			var x_dist = abs(position.x - _tracking.position.x)
			if x_dist > stop_dist:
				_idle_time = 0.0
				position.x = move_toward(position.x, _tracking.position.x, x_speed * delta)
			else:
				_idle_time += delta
				if _idle_time > attack_idle_time and _can_attack:
					_attack()
		State.ATTACK_WINDUP:
			pass

func _get_ground_y() -> float:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, Vector2.DOWN * _GROUND_RAYCAST_DISTANCE, Constants.ENVIRONMENT_LAYER)
	var result := space_state.intersect_ray(query)
	assert(!result.is_empty())
	return result.get("position").y

func _attack() -> void:
	var dx := _tracking.position.x - position.x
	var dy := fly_height
	_state = State.ATTACK_WINDUP
	await get_tree().create_timer(attack_windup_time).timeout
	assert(_state == State.ATTACK_WINDUP)
	_state = State.TRACKING if _tracking else State.IDLE
	var angle := _firing_angle(projectile_speed, dx, dy)
	var p := projectile.instantiate() as ArcProjectile
	get_tree().root.add_child(p)
	p.fire(projectile_speed, angle)
	p.position = position
	_can_attack = false
	await get_tree().create_timer(attack_cooldown_time).timeout
	assert(not _can_attack)
	_can_attack = true

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
	print("Vulture damage taken")

func _on_health_died() -> void:
	print("Vulture died")
	queue_free()

static func _firing_angle(v: float, dx: float, dy: float) -> float:
	const GRAVITY = 980.0

	var a := -((GRAVITY * pow(dx, 2)) / (2 * pow(v, 2)))
	var b := dx
	var c := dy + a
	var discriminant = pow(b, 2) - (4 * a * c)
	# If this fails, our vulture is misconfigured
	assert(discriminant > 0)
	var root := sqrt(discriminant)
	var angle1 := atan((-b - root) / (2 * a))
	var angle2 := atan((-b + root) / (2 * a))

	if dx > 0:
		# angle1 should be in the 1st quadrant
		assert(angle1 > 0)
		# Negate to put into Godot's coordinate system (-y points upwards)
		return -angle1
	else:
		# angle2 should be in the 4th quadrant
		assert(angle2 < 0)
		# Translate to the 2nd quadrant (for Godot's coordinate system)
		return -PI - angle2
