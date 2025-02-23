class_name Shooter extends FollowEnemy

@export var y_attack_cutoff := 50

func _attack() -> void:
	_state = State.ATTACKING
	while $Weapon.ammo > 0:
		await $Weapon.fire($Direction)
	_state = State.TRACKING
	await $Weapon.reload()

func _can_attack() -> bool:
	var y_distance = abs(global_position.y - Player.Instance.global_position.y);
	return !$Weapon.is_reloading and y_distance <= y_attack_cutoff
