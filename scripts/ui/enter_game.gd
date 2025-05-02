extends Button

@export var hover_offset: Vector2 = Vector2(0, -10)

@onready var _original_pos = position

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	HubManager.go_to_hub()

func _process(_delta: float) -> void:
	if is_hovered():
		position = _original_pos + hover_offset
	else:
		position = _original_pos
