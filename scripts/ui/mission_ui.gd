class_name MissionUI extends CanvasLayer

@export var lightning_ui: PackedScene
@export var acid_rain_ui: PackedScene
@export var survival_ui: PackedScene

func _ready() -> void:
	# Weather UI
	if MissionManager.mission.weather is AcidRain:
		add_child(acid_rain_ui.instantiate())
	if MissionManager.mission.weather is Lightning:
		add_child(lightning_ui.instantiate())
	
	# Mission UI
	if MissionManager.mission is SurvivalMission:
		add_child(survival_ui.instantiate())
