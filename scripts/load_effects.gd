class_name LoadEffects extends CanvasLayer

@export var duration: float = 1.0

func load_in() -> void:
	$TextureRect.modulate.a = 0
	var tween := get_tree().create_tween()
	tween.tween_property($TextureRect, "modulate:a", 1, duration)
	await tween.finished

func load_out() -> void:
	$TextureRect.modulate.a = 1
	var tween := get_tree().create_tween()
	tween.tween_property($TextureRect, "modulate:a", 0, duration)
	await tween.finished
