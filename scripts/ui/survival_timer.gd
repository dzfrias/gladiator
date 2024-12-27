extends Label

func _ready() -> void:
	assert(MissionManager.mission is SurvivalMission)
	text = "%.1f" % MissionManager.mission.time

func _process(_delta: float) -> void:
	text = "%.1f" % MissionManager.mission.time
