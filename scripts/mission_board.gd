class_name MissionBoard extends Interactable

var missions: Array[Mission] = []

func _ready() -> void:
	did_interact.connect(_on_interact)
	var mission := ConquerMission.new()
	mission.buckles = 20
	mission.weather = Lightning.new()
	missions.append(mission)

func _on_interact() -> void:
	HubManager.open_mission_select_screen()
