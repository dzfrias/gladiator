class_name MissionBoardScreen extends CanvasLayer

var _board_item_scene = preload("res://scenes/mission_board_item.tscn")

func _ready() -> void:
	$Return.pressed.connect(_on_quit_pressed)
	var buckles := PersistentData.buckles
	$BucklesLabel.text = "Buckles: " + str(buckles)
	
	for mission in HubManager.world.mission_board.missions:
		var board_item := _board_item_scene.instantiate() as MissionBoardItem
		board_item.set_to_mission(mission)
		board_item.mission_entered.connect(_on_mission_entered)
		$Missions.add_child(board_item)
	
	var buttons = get_all_buttons(self)
	for button in buttons:
		button.mouse_entered.connect(on_button_hovered)
		button.pressed.connect(on_button_pressed)

func get_all_buttons(node):
	var buttons = []
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		buttons += get_all_buttons(child)
	return buttons

func on_button_hovered():
	AudioManager.play_ui_sound(get_tree().current_scene, load("res://assets/SoundEffects/ui_select_1.wav"), -15)

func on_button_pressed():
	AudioManager.play_ui_sound(get_tree().current_scene, load("res://assets/SoundEffects/ui_select_2.wav"), -15)

func _on_quit_pressed() -> void:
	HubManager.return_to_world()

func _on_mission_entered(mission: Mission) -> void:
	HubManager.enter_mission(mission)
