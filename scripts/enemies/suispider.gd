class_name Suispider extends FollowEnemy

@export var damage: float = 5.0
@export var explode_time: float = 9.0
@export var distraction_jump_velocity: Vector2 = Vector2(300, -500.0)
@export var distraction_jump_time: float = 0.5

var _started_timer: bool = false

func _attack() -> void:
	if !_started_timer:
		_startLightningTimer()
	_state = State.ATTACKING
	velocity.y = distraction_jump_velocity.y
	velocity.x = $Direction.scalar * distraction_jump_velocity.x
	await get_tree().create_timer(distraction_jump_time).timeout
	assert(_state == State.ATTACKING)
	_state = State.TRACKING

func _startLightningTimer() -> void:
	_started_timer = true
	await get_tree().create_timer(explode_time).timeout
	if $ExplosionZone.has_overlapping_bodies():
		for node in $ExplosionZone.get_overlapping_bodies():
			var player := node as Player
			player.damage(damage, Vector2.ZERO)	
	$Health.take_damage(1000000, Vector2.ZERO)
