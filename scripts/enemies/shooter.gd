class_name Shooter extends FollowEnemy

func _attack() -> void:
	_state = State.ATTACKING
	while $Weapon.ammo > 0:
		await $Weapon.fire($Direction)
	_state = State.TRACKING
	await $Weapon.reload()

func _can_attack() -> bool:
	return !$Weapon.is_reloading
