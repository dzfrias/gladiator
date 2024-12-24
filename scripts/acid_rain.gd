class_name AcidRain extends RayCast2D

@export var debug_line: Line2D
@export var time_between_damage: float = 1
@export var damage: float = 2
@export var cycle_off_mean_time := 10.0
@export var cycle_off_sd := 2.5
@export var cycle_on_mean_time := 9.0
@export var cycle_on_sd := 1.5

var _can_damage := true

signal timer_changed(timer: SceneTreeTimer)

func _ready() -> void:
	_cycle()

func _process(_delta: float) -> void:
	global_position.x = Player.Instance.global_position.x

	_move_debug_line()
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

func _move_debug_line():
	debug_line.clear_points()
	debug_line.global_position = global_position
	debug_line.add_point(Vector2.ZERO, 0)
	debug_line.add_point(target_position, 1)

func _cycle():
	var line_width = debug_line.width
	while true:
		enabled = false
		debug_line.width = 0
		var wait_time = randfn(cycle_off_mean_time, cycle_off_sd)
		var timer = get_tree().create_timer(wait_time)
		timer_changed.emit(timer)
		await timer.timeout
		enabled = true
		debug_line.width = line_width
		var on_time = randfn(cycle_on_mean_time, cycle_on_sd)
		timer = get_tree().create_timer(on_time)
		timer_changed.emit(timer)
		await timer.timeout
