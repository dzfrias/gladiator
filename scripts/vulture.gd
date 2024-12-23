class_name Vulture extends Area2D

# Movement
@export var x_speed := 200.0
@export var y_speed := 100.0
@export var y_acceleration := 400.0
@export var x_acceleration := 300.0
@export var stop_dist := 300.0
@export var fly_height := 300.0
# Attacking
@export var attack_idle_time := 1.0
@export var attack_windup_time := 0.3
@export var attack_cooldown_time := 2.0
@export var projectile: PackedScene
@export var projectile_speed := 500.0
# Flapping
@export var flap_interval_time := 0.8
@export var flap_y_speed_mean := 100.0
@export var flap_y_speed_sd := 10.0
@export var flap_x_speed_mean := 30.0
@export var flap_x_speed_sd := 15.0

var _state := State.IDLE
var _tracking: Node2D
var _idle_time := 0.0
var _can_attack := true
var _velocity := Vector2.ZERO
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
	_start_periodic_flap()

func _process(delta: float) -> void:
	var ground_y := _get_ground_y()
	# This is the distance from the optimal idle position in the y axis
	# this number will almost always be greater than zero
	var fly_target := (ground_y - fly_height) - position.y
	if fly_target > 1:
		# Set our velocity to move us down (closer to fly target)
		_velocity.y = move_toward(_velocity.y, y_speed, y_acceleration * delta)
	
	match _state:
		State.IDLE:
			# TODO patrol
			pass
		State.TRACKING:
			assert(_tracking != null)
			var x_dist := position.x - _tracking.position.x
			if absf(x_dist) > stop_dist:
				_idle_time = 0.0
				var target_speed := x_speed * -signf(x_dist)
				# Velocity to point us towards our target
				_velocity.x = move_toward(_velocity.x, target_speed, x_acceleration * delta)
			else:
				_idle_time += delta
				if _idle_time > attack_idle_time and _can_attack and fly_target < 1:
					_attack()
		State.ATTACK_WINDUP:
			pass
	
	position += _velocity * delta

func _get_ground_y() -> float:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, Vector2.DOWN * _GROUND_RAYCAST_DISTANCE, Constants.ENVIRONMENT_LAYER)
	var result := space_state.intersect_ray(query)
	# We _should_ always be over the ground
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

func _start_periodic_flap() -> void:
	var flap_x_multiplier := 1.0
	while true:
		await get_tree().create_timer(flap_interval_time).timeout
		_velocity.y = -randfn(flap_y_speed_mean, flap_y_speed_sd)
		# We only want to flap sideways if we're idle
		if _idle_time > 0:
			_velocity.x = randfn(flap_x_speed_mean, flap_x_speed_sd) * flap_x_multiplier
			# Alternates between 1 and -1 (flapping back and forth on the x-axis)
			flap_x_multiplier *= -1.0

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
