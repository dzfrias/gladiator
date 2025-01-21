extends ProgressBar

@export var health: Health

func _ready() -> void:
	max_value = health.max_health
	health.damage_taken.connect(_on_health_lost)
	health.health_gained.connect(_on_health_gained)

func _on_health_lost(amount: float):
	value -= amount
	
func _on_health_gained(amount: float):
	value += amount
