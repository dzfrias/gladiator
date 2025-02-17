class_name Shooter extends FollowEnemy

@export_category("Movement")
@export var y_cutoff: float = 100.0
@export var y_axis_follow_time: float = 1.0

var _player_follow_time: float = 0.0

func _attack() -> void:
	_state = State.ATTACKING
	while $Weapon.ammo > 0:
		await $Weapon.fire($Direction)
	_state = State.TRACKING
	await $Weapon.reload()

func _can_attack() -> bool:
	return !$Weapon.is_reloading
