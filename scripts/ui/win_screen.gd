extends Menu

@export var fade_duration: float = 2.0

func _ready() -> void:
	super()
	$RestartButton.pressed.connect(_on_restart_button_pressed)
	var tween := get_tree().create_tween()
	tween.tween_property($Fade, "color:a", 0.0, fade_duration)

func _on_restart_button_pressed() -> void:
	PersistentData.reset()
	HubManager.go_to_hub()
