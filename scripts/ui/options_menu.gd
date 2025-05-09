extends Menu

signal options_menu_closed

@onready var master_volume_slider: HSlider = $VBoxContainer/MasterVolumeSlider
@onready var music_volume_slider: HSlider = $VBoxContainer/MusicSlider

func _ready():
	$VBoxContainer/BackButton.pressed.connect(_on_back_btn_pressed)
	master_volume_slider.value = AudioServer.get_bus_volume_db(Constants.MASTER_BUS_INDEX)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value = AudioServer.get_bus_volume_db(Constants.MUSIC_BUS_INDEX)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	$VBoxContainer/FullscreenToggleContainer/FullscreenToggle.toggled.connect(_on_fullscreen_toggled)
	$VBoxContainer/FullscreenToggleContainer/FullscreenToggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	$VBoxContainer/Resolutions.item_selected.connect(_on_resolution_selected)

func _on_back_btn_pressed():
	options_menu_closed.emit()

func _on_master_volume_changed(value: float):
	_adjust_volume(Constants.MASTER_BUS_INDEX, value)

func _on_music_volume_changed(value: float):
	_adjust_volume(Constants.MUSIC_BUS_INDEX, value)

func _adjust_volume(bus_index, value: float):
	AudioServer.set_bus_volume_db(bus_index, value)
	if value == master_volume_slider.min_value:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

func _on_fullscreen_toggled(toggle: bool):
	if toggle:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolution_selected(index: int):
	var text = $VBoxContainer/Resolutions.get_item_text(index) as String
	var x = int(text.split("x")[0])
	var y = int(text.split("x")[1])
	DisplayServer.window_set_size(Vector2i(x, y))
