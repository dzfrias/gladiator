class_name Suispider extends FollowEnemy

@export var damage: float = 5.0
@export var self_damage: float = 2.0
@export var explode_time: float = 2.0
@export var distraction_jump_velocity: Vector2 = Vector2(300, -500.0)

var _started_timer: bool = false

func _attack() -> void:
	if !_started_timer:
		_start_lightning_timer()
	_state = State.ATTACKING
	velocity.y = distraction_jump_velocity.y
	velocity.x = $Direction.scalar * distraction_jump_velocity.x
	await hit_floor
	assert(_state == State.ATTACKING)
	_state = State.TRACKING

func _start_lightning_timer() -> void:
	_started_timer = true
	while true:
		await get_tree().create_timer(explode_time).timeout
		for node in $ExplosionZone.get_overlapping_bodies():
			var player := node as Player
			player.damage(damage, Vector2.ZERO)
		Debug.draw_circle(position, $ExplosionZone/CollisionShape2D.shape.radius)
		$Health.take_damage(self_damage, Vector2.ZERO)
