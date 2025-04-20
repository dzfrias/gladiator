extends CanvasItem

@export var interval: float = 1.0

func _ready() -> void:
	_blink()

func _blink() -> void:
	while true:
		visible = true
		await get_tree().create_timer(interval).timeout
		visible = false
		await get_tree().create_timer(interval).timeout
