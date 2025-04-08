class_name IdleShooter extends CharacterBody2D

@export var prepare_attack_time := 0.25
@export var idle_time: float = 1
@export var impact_particle_prefab: PackedScene
@export var y_attack_cutoff = 50
@export var notify_depth = 2
@export var initially_is_right: bool = false

@onready var weapon: Weapon = $Weapon
var _state: State = State.HIDING
@onready var _tracking: Node2D = Player.Instance
var _is_shooting: bool = false
var _notified: bool = false

signal on_state_changed(state)

enum State {
	HIDING,
	STANDING,
	SHOOTING,
}

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	$Direction.is_right = initially_is_right
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match _state:
		State.HIDING:
			var xdist := _tracking.position.x - position.x
			$StandCollision.disabled = true
			$HideCollision.disabled = false
			$Direction.scalar = signf(xdist)
			
			var y_distance = abs(global_position.y - Player.Instance.global_position.y)
			if (weapon.ammo > 0 or _tracking_is_behind()) and _notified and y_distance <= y_attack_cutoff:
				_state = State.STANDING
				on_state_changed.emit(_state)
		State.STANDING:
			var xdist := _tracking.position.x - position.x
			$Direction.scalar = signf(xdist)
			$HideCollision.disabled = true
			$StandCollision.disabled = false
			
			if not _is_shooting and weapon.ammo > 0:
				_shoot()
	
	move_and_slide()

func notify(depth: int) -> void:
	_notified = true
	if depth > 0:
		for body in $NotifyZone.get_overlapping_bodies():
			if body == self:
				continue
			body.notify(depth - 1)

func _shoot() -> void:
	assert(not _is_shooting)
	
	notify(notify_depth)
	_is_shooting = true
	await get_tree().create_timer(prepare_attack_time).timeout
	_state = State.SHOOTING
	on_state_changed.emit(_state)
	while weapon.ammo > 0:
		await weapon.fire($Direction)
	_state = State.STANDING
	on_state_changed.emit(_state)
	await get_tree().create_timer(idle_time).timeout
	_is_shooting = false
	
	assert(_state == State.STANDING)
	if not _tracking_is_behind():
		_hide()
	else:
		weapon.reload()

func _hide():
	assert(not _tracking_is_behind())
	_state = State.HIDING
	on_state_changed.emit(_state)
	weapon.reload()

func _tracking_is_behind() -> bool:
	return $Direction.is_right != initially_is_right

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		notify(notify_depth)

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	var impact_particles = impact_particle_prefab.instantiate()
	impact_particles.global_position = global_position
	get_tree().current_scene.add_child(impact_particles)
	impact_particles.direction = _direction
	impact_particles.emitting = true

func _on_health_died() -> void:
	queue_free()
