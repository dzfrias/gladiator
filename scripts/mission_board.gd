class_name MissionBoard extends Interactable

var missions: Array[Mission] = []

func _ready() -> void:
	did_interact.connect(_on_interact)
	var mission := ConquerMission.new()
	var mission2 := ConquerMission.new()
	var mission3 := ConquerMission.new()
	
	mission.buckles = 20
	mission.weather = Lightning.new()
	missions.append(mission)
	
	mission2.buckles = 10
	mission2.weather = AcidRain.new()
	missions.append(mission2)

	mission3.buckles = 10
	mission3.weather = Flood.new()
	missions.append(mission3)

func _on_interact() -> void:
	HubManager.open_mission_select_screen()
