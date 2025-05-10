extends ProgressBar

var health
@export var tween_duration: float = 0.05

func _ready() -> void:
	health = Player.Instance.get_health()
	max_value = health.max_health
	health.damage_taken.connect(_on_health_lost)
	health.health_gained.connect(_on_health_gained)
	health.max_health_changed.connect(_on_max_health_changed)

func set_health(obj: Health):
	health = obj

func _on_max_health_changed() -> void:
	max_value = health.max_health
	value = health.health

func _on_health_lost(_amount: float, _direction: Vector2):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "value", health.health, tween_duration)
	tween.set_ease(Tween.EaseType.EASE_IN)

func _on_health_gained(_amount: float):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "value", health.health, tween_duration)
	tween.set_ease(Tween.EaseType.EASE_IN)
	await tween.finished
