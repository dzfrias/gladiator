class_name Menu extends Node

func _ready() -> void:
	var buttons = get_all_buttons(self)
	for button in buttons:
		button.mouse_entered.connect(_on_button_hovered)
		button.pressed.connect(_on_button_pressed)
	
	get_tree().node_added.connect(_on_node_added)

func get_all_buttons(node: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		buttons += get_all_buttons(child)
	return buttons

func _on_button_hovered() -> void:
	AudioManager.play_ui_sound(get_tree().current_scene, load("res://assets/SoundEffects/ui_select_1.wav"), -15)

func _on_button_pressed() -> void:
	AudioManager.play_ui_sound(get_tree().current_scene, load("res://assets/SoundEffects/ui_select_2.wav"), -15)

func _on_node_added(node: Node) -> void:
	if node is Button:
		node.mouse_entered.connect(_on_button_hovered)
		node.pressed.connect(_on_button_pressed)
