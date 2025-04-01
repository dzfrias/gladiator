class_name SniperEffects extends Node

@export var zoom_delta: float = 0.25
@export var tween_duration: float = 0.1
@export var speed_factor: float = 0.9

var _cam: Camera2D

func _enter_tree() -> void:
	_cam = Player.Instance.camera() as Camera2D
	var tween = get_tree().create_tween()
	tween.tween_property(_cam, "zoom", _cam.zoom - Vector2(zoom_delta, zoom_delta), tween_duration)

func _process(_delta: float) -> void:
	if not Player.Instance.is_underground():
		Player.Instance.velocity *= speed_factor

func _exit_tree() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(_cam, "zoom", _cam.zoom + Vector2(zoom_delta, zoom_delta), tween_duration)
