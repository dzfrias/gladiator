class_name MissionBoard extends Area2D

var missions: Array[Mission] = []

func _ready() -> void:
	$Interactable.did_interact.connect(_on_interact)
	var mission := ConquerMission.new()
	mission.buckles = 20
	mission.weather = Lightning.new()
	missions.append(mission)

func _on_interact() -> void:
	HubManager.open_mission_select_screen()
