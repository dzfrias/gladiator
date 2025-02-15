class_name IdleShooter extends CharacterBody2D

@export_category("Shooting")
@export var projectile: PackedScene
@export var projectile_speed := 800.0
@export var projectile_damage := 4.0
@export var prepare_attack_time := 0.25
@export var shoot_cooldown_avg: float = 1.4
@export var shoot_cooldown_sd: float = 0.2
@export var idle_time: float = 1
@export var hide_time: float = 5
@export var max_ammo: int = 3

@export var impact_particle_prefab: PackedScene

@onready var detection_zone = $DetectionZone
@onready var firing_position = $FiringPosition

var _state: State = State.HIDING
@onready var _tracking: Node2D = Player.Instance
var _can_attack: bool = true
var _can_stand: bool = true
var _direction
var ammo: int

enum State {
	HIDING,
	STANDING,
	SHOOTING,
}

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	ammo = max_ammo

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match _state:
		State.HIDING:
			var xdist := _tracking.position.x - position.x
			_direction = signf(xdist)
			scale.x = _direction
			if detection_zone.has_overlapping_bodies() and _can_stand:
				_stand()
		State.STANDING:
			scale.y = 1
			var xdist := _tracking.position.x - position.x
			_direction = signf(xdist)
			scale.x = _direction
			if ammo <= 0:
				_hide()
			
			if _can_attack:
				_shoot(_direction)

func _shoot(direction: float) -> void:
	_state = State.SHOOTING
	await get_tree().create_timer(prepare_attack_time).timeout
	var p := projectile.instantiate() as HorizontalProjectile
	get_tree().root.add_child(p)
	var angle: float
	if direction == 1:
		angle = 0.0
	else:
		angle = PI
	p.fire(projectile_speed, angle)
	p.damage = projectile_damage
	p.global_position = firing_position.global_position
	ammo -= 1
	await get_tree().create_timer(idle_time).timeout
	_state = State.STANDING
	_can_attack = false
	var wait := randfn(shoot_cooldown_avg, shoot_cooldown_sd)
	await get_tree().create_timer(wait).timeout
	_can_attack = true

func _stand():
	_state = State.STANDING

func _hide():
	_state = State.HIDING
	_can_stand = false
	scale.y = 0.5
	await get_tree().create_timer(hide_time).timeout
	_can_stand = true
	ammo = max_ammo

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	var impact_particles = impact_particle_prefab.instantiate()
	impact_particles.global_position = global_position
	get_tree().root.add_child(impact_particles)
	impact_particles.direction = _direction
	impact_particles.emitting = true
	
	print("Shooter damage taken")

func _on_health_died() -> void:
	print("Shooter died")
	queue_free()
