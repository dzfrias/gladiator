class_name Lightning extends Node2D

@export var tolerance_time := 8.0
@export var damage := 3.0

var current_time := 0.0

func _process(delta: float) -> void:
	var player: Player = Player.Instance
	if player.is_holding_weapon():
		current_time += delta
		if current_time >= tolerance_time:
			current_time = 0
			player.damage(damage, Vector2.ZERO)
	else:
		current_time = maxf(current_time - delta, 0)
