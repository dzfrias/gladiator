class_name LightningIndicator extends ProgressBar

var _lightning: Lightning

func _ready() -> void:
	assert(MissionManager.mission.weather is Lightning)
	_lightning = MissionManager.mission.weather as Lightning
	value = 0
	max_value = _lightning.tolerance_time

func _process(_delta: float) -> void:
	value = _lightning.current_time
