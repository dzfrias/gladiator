class_name BurrowBar extends ProgressBar

func _ready() -> void:
	value = 0
	max_value = Player.Instance.movement_settings.max_burrow_time

func _process(_delta: float) -> void:
	ratio = 1 - Player.Instance.burrow_percentage()
