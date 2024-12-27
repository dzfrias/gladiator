class_name AcidRainIndicator extends ProgressBar

var _acid_rain: AcidRain
var _timer: SceneTreeTimer

func _ready() -> void:
	assert(MissionManager.weather is AcidRain)
	_acid_rain = MissionManager.weather as AcidRain
	_acid_rain.timer_changed.connect(_on_acid_rain_timer_changed)
	value = 0

func _process(_delta: float) -> void:
	if not _timer: return
	if _acid_rain.enabled:
		ratio = _timer.time_left / max_value
	else:
		ratio = 1 - _timer.time_left / max_value

func _on_acid_rain_timer_changed(timer: SceneTreeTimer) -> void:
	_timer = timer
	max_value = timer.time_left
