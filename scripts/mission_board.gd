class_name MissionBoard extends Interactable

var missions: Array[Mission] = []

func _ready() -> void:
	did_interact.connect(_on_interact)
	
	if not PersistentData.done_tutorial:
		var mission := TutorialMission.new()
		mission.buckles = 0
		missions.append(mission)
		return
	
	for i in range(3):
		var mission = ConquerMission.new()
		
		mission.difficulty = i as Mission.Difficulty
		var weather_index := randi_range(0, 2)
		match weather_index:
			0: mission.weather = Lightning.new()
			1: mission.weather = AcidRain.new()
			2: mission.weather = Flood.new()
		match mission.difficulty:
			Mission.Difficulty.EASY: mission.buckles = 20
			Mission.Difficulty.MEDIUM: mission.buckles = 40
			Mission.Difficulty.HARD: mission.buckles = 60
		missions.append(mission)
	
func _on_interact() -> void:
	HubManager.open_mission_select_screen()
