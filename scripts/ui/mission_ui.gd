class_name MissionUI extends CanvasLayer

@export var acid_rain_ui: PackedScene
@export var survival_ui: PackedScene

func _ready() -> void:
	# TODO: remove this code
	if MissionManager.mission == null:
		return
	
	# Mission UI
	if MissionManager.mission is SurvivalMission:
		add_child(survival_ui.instantiate())
