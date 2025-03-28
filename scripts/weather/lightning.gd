class_name Lightning extends Node2D

@export var tolerance_time := 8.0
@export var damage := 3.0

var current_time := 0.0

func _process(delta: float) -> void:
	if not MissionManager.mission.in_combat:
		current_time = 0
		return
	
	var player: Player = Player.Instance
	current_time += delta
	if current_time >= tolerance_time:
		current_time = 0
		if not player.is_underground():
			player.damage(damage, Vector2.ZERO)
