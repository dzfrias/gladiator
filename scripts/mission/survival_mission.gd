class_name SurvivalMission extends Mission

var time := 30.0

func _process(delta: float) -> void:
	time -= delta
	if time <= 0:
		mission_finished.emit()
