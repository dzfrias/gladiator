extends CanvasLayer

signal options_menu_closed

func _ready():
	$Control/BackButton.pressed.connect(_on_back_btn_pressed)

func _on_back_btn_pressed():
	hide()
	options_menu_closed.emit()
