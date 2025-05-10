class_name MissionBoardItem extends Control

signal mission_entered(mission: Mission)

var _mission: Mission

func _ready() -> void:
	$EnterButton.pressed.connect(_on_entered)

func set_to_mission(mission: Mission):
	_mission = mission
	var mission_name: String
	if mission is ConquerMission:
		mission_name = "Conquer"
	elif mission is SurvivalMission:
		mission_name = "Survive"
	elif mission is TutorialMission:
		mission_name = "Tutorial"
	else:
		assert(false)
	
	var weather_name: String
	if mission.weather is Lightning:
		weather_name = "Lightning"
	elif mission.weather is AcidRain:
		weather_name = "Acid Rain"
	elif mission.weather is Flood:
		weather_name = "Flood"
	else:
		weather_name = "None"
	
	var difficulty_str: String
	match mission.difficulty:
		Mission.Difficulty.EASY:
			difficulty_str = "Easy"
		Mission.Difficulty.MEDIUM:
			difficulty_str = "Medium"
		Mission.Difficulty.HARD:
			difficulty_str = "Hard"
	
	$Description/MissionLabel.text = mission_name
	$Description/BucklesLabel.text = str(mission.buckles)
	$DifficultyLabel.text = "Difficulty: " + difficulty_str
	$WeatherLabel.text = weather_name

func _on_entered():
	mission_entered.emit(_mission)
