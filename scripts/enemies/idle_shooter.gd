class_name IdleShooter extends Enemy

@export var prepare_attack_time := 0.25
@export var idle_time: float = 1
@export var impact_particle_prefab: PackedScene
@export var y_attack_cutoff = 50
@export var initially_is_right: bool = false

@onready var weapon: Weapon = $Weapon
var _state: State = State.HIDING
@onready var _tracking: Node2D = Player.Instance
@onready var _original_weapon_x = $Weapon.position.x
var _is_shooting: bool = false
var _notified: bool = false

signal on_state_changed(state)

enum State {
	HIDING,
	STANDING,
	SHOOTING,
}

func _ready() -> void:
	super()
	$Direction.is_right = initially_is_right

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
	
	move()
	_align_with_direction()

func notify(depth: int = 0) -> void:
	_notified = true
	super()

func _shoot() -> void:
	assert(not _is_shooting)
	
	notify(notify_depth)
	_is_shooting = true
	
	$Weapon.activate_prefire_flash()
	await get_tree().create_timer(prepare_attack_time).timeout
	$Weapon.deactivate_prefire_flash()
	
	_state = State.SHOOTING
	on_state_changed.emit(_state)
	while weapon.ammo > 0:
		await weapon.fire($Direction.angle)
	
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

func _align_with_direction() -> void:
	$Weapon.position.x = _original_weapon_x * $Direction.scalar

func _on_health_damage_taken(_amount: float, _direction: Vector2):
	super(_amount, _direction)
	AudioManager.play_sound(self, load("res://assets/SoundEffects/hit.wav"))
