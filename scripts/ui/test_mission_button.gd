extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var mission = ConquerMission.new()
	mission.buckles = 10
	mission.weather = Lightning.new()
	MissionManager.enter_mission(mission, [])
