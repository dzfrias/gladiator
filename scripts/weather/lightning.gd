class_name Lightning extends Node2D

@export var strike_time_min := 5.0
@export var strike_time_max := 7.0
@export var damage := 3.0
@export var warning_interval_time := 0.15
@export var warning_amount: int = 5
@export var strike_scene: PackedScene = preload("res://scenes/lightning_strike.tscn")

func _ready() -> void:
	_begin_striking()

func _begin_striking() -> void:
	while true:
		await get_tree().create_timer(randf_range(strike_time_min, strike_time_max)).timeout
		if not MissionManager.mission.in_combat:
			continue
		await _strike()

func _strike() -> void:
	var strike_time := (warning_amount / 2) * warning_interval_time
	var pos: Vector2 = Player.Instance.global_position + Player.Instance.velocity * strike_time
	for _i in range(warning_amount):
		Debug.draw_line(
			pos + Vector2.UP * 1000.0,
			pos + Vector2.DOWN * 1000.0,
			5.0,
			Color.YELLOW,
			0.05,
		)
		await get_tree().create_timer(warning_interval_time).timeout
	
	var strike := strike_scene.instantiate() as Node2D
	strike.global_position = pos
	get_tree().current_scene.add_child(strike)
