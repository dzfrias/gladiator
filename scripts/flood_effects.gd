class_name FloodEffects extends CanvasLayer

@export var transition_time: float = 0.7

@onready var screen_height = DisplayServer.screen_get_size().y

func _ready() -> void:
	_flood()

func _process(_delta: float) -> void:
	$ColorRect.position.y = screen_height - $ColorRect.size.y

func _flood() -> void:
	$ColorRect.size.y = 0.0
	var tween := get_tree().create_tween()
	tween.tween_property($ColorRect, "size", Vector2($ColorRect.size.x, screen_height), transition_time)
