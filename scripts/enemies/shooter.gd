class_name Shooter extends FollowEnemy

@export var y_attack_cutoff := 50
@export var attack_windup_time := 0.75

@onready var _original_weapon_x = $Weapon.position.x

func _physics_process(delta: float) -> void:
	super(delta)
	_align_with_direction()

func _attack() -> void:
	_state = State.TIRED
	on_state_changed.emit(_state)
	$Weapon.activate_prefire_flash()
	await get_tree().create_timer(attack_windup_time).timeout
	$Weapon.deactivate_prefire_flash()
	_state = State.ATTACKING
	on_state_changed.emit(_state)
	while $Weapon.ammo > 0:
		await $Weapon.fire($Direction)
	_state = State.TRACKING
	on_state_changed.emit(_state)
	await $Weapon.reload()

func _can_attack() -> bool:
	var y_distance = abs(global_position.y - Player.Instance.global_position.y)
	return !$Weapon.is_reloading and y_distance <= y_attack_cutoff

func _align_with_direction() -> void:
	$Weapon.position.x = _original_weapon_x * $Direction.scalar

func _on_health_damage_taken(amount: float, direction: Vector2):
	super(amount, direction)
	AudioManager.play_sound(self, load("res://assets/SoundEffects/lil hit idk.wav"))
