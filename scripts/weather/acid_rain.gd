class_name AcidRain extends RayCast2D

@export var time_between_damage: float = 1
@export var damage: float = 2
@export var cycle_off_mean_time := 10.0
@export var cycle_off_sd := 2.5
@export var cycle_on_mean_time := 9.0
@export var cycle_on_sd := 1.5

var _can_damage := true

signal timer_changed(timer: SceneTreeTimer)

func _ready() -> void:
	collision_mask = Constants.ENVIRONMENT_LAYER | Constants.ROOF_LAYER | Constants.PLAYER_LAYER
	_cycle()

func _process(_delta: float) -> void:
	global_position.x = Player.Instance.global_position.x

	if is_colliding():
		var collider = get_collider()
		if collider is Player and _can_damage:
			var player = collider as Player
			player.damage(damage)
			_damage_cooldown()

func _damage_cooldown():
	_can_damage = false
	await get_tree().create_timer(time_between_damage).timeout
	_can_damage = true

func _cycle():
	while true:
		enabled = false
		var wait_time = randfn(cycle_off_mean_time, cycle_off_sd)
		var timer = get_tree().create_timer(wait_time)
		timer_changed.emit(timer)
		await timer.timeout
		enabled = true
		var on_time = randfn(cycle_on_mean_time, cycle_on_sd)
		timer = get_tree().create_timer(on_time)
		timer_changed.emit(timer)
		await timer.timeout