extends AOEDamage

func _align() -> void:
	super()
	$CPUParticles2D.direction = Vector2(_direction.scalar, 0)
