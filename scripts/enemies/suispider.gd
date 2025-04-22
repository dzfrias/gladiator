class_name Suispider extends FollowEnemy

@export var damage: float = 5.0
@export var self_damage: float = 2.0
@export var explosion_scale_factor: float = 0.65
@export var explode_time: float = 2.0
@export var distraction_jump_velocity: Vector2 = Vector2(300, -500.0)
@export var lightning_strike_scene: PackedScene = preload("res://scenes/lightning_strike.tscn")

var _started_timer: bool = false

signal jumped
signal called_lightning
signal called_lightning_pre

func _attack() -> void:
	if !_started_timer:
		_start_lightning_timer()
	jumped.emit()
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
		called_lightning_pre.emit()
		await get_tree().create_timer(0.7).timeout
		called_lightning.emit()
		var strike := lightning_strike_scene.instantiate() as Explosion
		strike.damage = damage
		strike.scale *= explosion_scale_factor
		get_tree().current_scene.add_child(strike)
		strike.global_position = global_position
		$Health.take_damage(self_damage, Vector2.ZERO)
