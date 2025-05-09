extends Menu

@export var options_menu: CanvasLayer

func _ready() -> void:
	super()
	self.visible = false
	$Control/ResumeButton.pressed.connect(_on_resume_btn_pressed)
	$Control/OptionsButton.pressed.connect(_on_options_btn_pressed)
	$Control/ReturnButton.pressed.connect(_on_return_btn_pressed)
	$Control/MainMenuButton.pressed.connect(_on_main_menu_btn_pressed)
	$OptionsCanvas/OptionsMenu.options_menu_closed.connect(_on_options_menu_closed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		if options_menu.visible:
			options_menu.hide()
			self.visible = true
		else:
			if !self.visible:
				Engine.time_scale = 0
				self.visible = true
			else:
				Engine.time_scale = 1
				self.visible = false
		get_viewport().set_input_as_handled()

func _on_resume_btn_pressed():
	Engine.time_scale = 1
	self.visible = false

func _on_options_btn_pressed():
	options_menu.show()
	self.visible = false

func _on_return_btn_pressed():
	if MissionManager.mission != null:
		MissionManager.mission._defeat()

func _on_main_menu_btn_pressed():
	print("_on_main_menu_btn_pressed")

func _on_options_menu_closed():
	options_menu.hide()
	self.visible = true
