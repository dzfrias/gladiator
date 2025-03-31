extends ProgressBar

@export var health: Health
@export var tween_duration: float = 0.05
@export var health_bar_offset = Vector2(-50, 100)

func _ready() -> void:
	max_value = health.max_health
	health.damage_taken.connect(_on_health_lost)
	health.health_gained.connect(_on_health_gained)
	health.died.connect(_on_death)
	hide()

func _process(_delta: float) -> void:
	global_position = health.get_parent().global_position + health_bar_offset

func set_health(obj: Health):
	health = obj

func _on_health_lost(amount: float, _direction: Vector2):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "value", value - amount, tween_duration)
	tween.set_ease(Tween.EaseType.EASE_IN)
	show()

func _on_health_gained(amount: float):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "value", value + amount, tween_duration)
	tween.set_ease(Tween.EaseType.EASE_IN)
	await tween.finished
	if ratio == 1.0:
		hide()

func _on_death():
	queue_free()
