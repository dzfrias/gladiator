extends ProgressBar

func _ready() -> void:
	var player_health = Player.Instance.get_health() as Health
	max_value = player_health.max_health
	player_health.damage_taken.connect(on_health_lost)
	player_health.health_gained.connect(on_health_gained)

func on_health_lost(amount: float):
	value -= amount
	
func on_health_gained(amount: float):
	value += amount
	
