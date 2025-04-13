class_name TweenedScaler extends Node2D

@export var duration: float = 0.05
@export var hold_duration: float = 0.05
@export var end_scale: float = 1.0
@export var auto_free: Node

func _ready() -> void:
	await get_tree().process_frame
	scale = Vector2.ONE * 0.2
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * end_scale, duration)
	tween.set_ease(Tween.EaseType.EASE_IN)
	await tween.finished
	
	if hold_duration >= 0.0:
		await get_tree().create_timer(hold_duration).timeout
		if auto_free != null:
			auto_free.queue_free()
		else:
			queue_free()
