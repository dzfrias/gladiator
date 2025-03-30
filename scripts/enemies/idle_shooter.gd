class_name IdleShooter extends CharacterBody2D

@export var prepare_attack_time := 0.25
@export var idle_time: float = 1
@export var impact_particle_prefab: PackedScene
@export var y_attack_cutoff = 50
@export var notify_depth = 2

@onready var weapon: Weapon = $Weapon
@onready var detection_zone = $DetectionZone
@onready var box_detection = $BoxDetection
var _state: State = State.HIDING
@onready var _tracking: Node2D = Player.Instance
var preparing_to_fire = false
var is_idle = false

var box_position: Vector2
var has_box: bool = false

signal on_state_changed(state)

enum State {
	HIDING,
	STANDING,
	SHOOTING,
}

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	await get_tree().create_timer(0.1).timeout
	if box_detection.is_colliding():
		has_box = true
		box_position = box_detection.get_collision_point()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match _state:
		State.HIDING:
			if !has_box:
				_state = State.STANDING
				on_state_changed.emit(_state)
			
			var xdist := _tracking.position.x - position.x
			$StandCollision.disabled = true
			$HideCollision.disabled = false
			$Direction.scalar = signf(xdist)
			if detection_zone.has_overlapping_bodies() and (weapon.ammo > 0 or !_is_box_inbetween()):
				_state = State.STANDING
				on_state_changed.emit(_state)
		State.STANDING:
			var xdist := _tracking.position.x - position.x
			$Direction.scalar = signf(xdist)
			$HideCollision.disabled = true
			$StandCollision.disabled = false
			
			var y_distance = abs(global_position.y - Player.Instance.global_position.y)
			if $DetectionZone.has_overlapping_bodies() and y_distance <= y_attack_cutoff:
				if weapon.ammo > 0:
					if !preparing_to_fire:
						_shoot()
				elif !is_idle:
					if !weapon.is_reloading:
						weapon.reload()
					elif has_box and _is_box_inbetween():
						_hide()
	
	move_and_slide()

func notify(depth: int) -> void:
	if depth > 0:
		for body in $NotifyZone.get_overlapping_bodies():
			if body == self:
				continue
			body.notify(depth - 1)

func _shoot() -> void:
	notify(notify_depth)
	preparing_to_fire = true
	await get_tree().create_timer(prepare_attack_time).timeout
	_state = State.SHOOTING
	on_state_changed.emit(_state)
	preparing_to_fire = false
	while weapon.ammo > 0:
		await weapon.fire($Direction)
	_state = State.STANDING
	on_state_changed.emit(_state)
	is_idle = true
	await get_tree().create_timer(idle_time).timeout
	is_idle = false
	if box_position and _is_box_inbetween():
		_hide()

func _is_box_inbetween():
	return sign(global_position.x - box_position.x) == sign(global_position.x - Player.Instance.global_position.x)

func _hide():
	_state = State.HIDING
	on_state_changed.emit(_state)
	if !weapon.is_reloading and weapon.ammo <= 0:
		await weapon.reload()

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	var impact_particles = impact_particle_prefab.instantiate()
	impact_particles.global_position = global_position
	get_tree().current_scene.add_child(impact_particles)
	impact_particles.direction = _direction
	impact_particles.emitting = true
	
	print("Shooter damage taken")

func _on_health_died() -> void:
	print("Shooter died")
	queue_free()
