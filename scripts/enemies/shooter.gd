class_name Shooter extends FollowEnemy

@export var y_attack_cutoff := 50
@export var attack_windup_time := 0.75
@export var weapon_stats: Array[WeaponStats]

@onready var _original_weapon_x = $Weapon.position.x

func _ready() -> void:
	super()
	var random_num = randi_range(0, weapon_stats.size() - 1)
	$Weapon.weapon_stats = weapon_stats[random_num]
	$GunOverlay.update_texture()

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
		await $Weapon.fire($Direction.angle)
	_state = State.TRACKING
	on_state_changed.emit(_state)
	await $Weapon.reload()

func _can_attack() -> bool:
	var y_distance = abs(global_position.y - Player.Instance.global_position.y)
	return !$Weapon.is_reloading and y_distance <= y_attack_cutoff

func _align_with_direction() -> void:
	$Weapon.position.x = _original_weapon_x * $Direction.scalar
