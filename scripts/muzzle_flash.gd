class_name MuzzleFlash extends Sprite2D

@export var duration: float = 0.05
@export var hold_duration: float = 0.05
@export var end_scale: float = 1.0

func _ready() -> void:
	scale = Vector2.ONE * 0.2

func activate() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * end_scale, duration)
	tween.set_ease(Tween.EaseType.EASE_IN)
	await tween.finished
	await get_tree().create_timer(hold_duration).timeout
	queue_free()
