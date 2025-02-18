class_name IdleShooter extends CharacterBody2D

@export var prepare_attack_time := 0.25
@export var idle_time: float = 1
@export var impact_particle_prefab: PackedScene

@onready var detection_zone = $DetectionZone
var _state: State = State.HIDING
@onready var _tracking: Node2D = Player.Instance
var _can_stand: bool = true

enum State {
	HIDING,
	STANDING,
	SHOOTING,
}

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match _state:
		State.HIDING:
			var xdist := _tracking.position.x - position.x
			$StandCollision.disabled = true
			$HideCollision.disabled = false
			$StandSprite.visible = false
			$HideSprite.visible = true
			$Direction.scalar = signf(xdist)
			if detection_zone.has_overlapping_bodies() and _can_stand:
				_state = State.STANDING
		State.STANDING:
			var xdist := _tracking.position.x - position.x
			$Direction.scalar = signf(xdist)
			$HideCollision.disabled = true
			$StandCollision.disabled = false
			$StandSprite.visible = true
			$HideSprite.visible = false
			
			_shoot()

func notify() -> void:
	for body in $NotifyZone.get_overlapping_bodies():
		if body == self:
			continue
		body.notify()

func _shoot() -> void:
	notify()
	_state = State.SHOOTING
	await get_tree().create_timer(prepare_attack_time).timeout
	while $Weapon.ammo > 0:
		await $Weapon.fire($Direction)
	await get_tree().create_timer(idle_time).timeout
	_hide()

func _hide():
	_state = State.HIDING
	_can_stand = false
	await $Weapon.reload()
	_can_stand = true

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
