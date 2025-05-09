class_name MissionBoardScreen extends Menu

var _board_item_scene = preload("res://scenes/mission_board_item.tscn")

func _ready() -> void:
	super()
	$Return.pressed.connect(_on_quit_pressed)
	var buckles := PersistentData.buckles
	$BucklesLabel.text = "Buckles: " + str(buckles)
	
	for mission in HubManager.world.mission_board.missions:
		var board_item := _board_item_scene.instantiate() as MissionBoardItem
		board_item.set_to_mission(mission)
		board_item.mission_entered.connect(_on_mission_entered)
		$Missions.add_child(board_item)

func _on_quit_pressed() -> void:
	HubManager.return_to_world()

func _on_mission_entered(mission: Mission) -> void:
	HubManager.enter_mission(mission)
