extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	MissionManager.mission = ConquerMission.new()
	MissionManager.mission.gold = 10
	MissionManager.weather = Lightning.new()
	MissionManager.enter_mission()
