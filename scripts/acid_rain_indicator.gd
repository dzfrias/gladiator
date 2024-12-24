class_name AcidRainIndicator extends ProgressBar

# TODO this shouldn't be an exported reference. Eventually, we will be setting up
# the UI and the random weather using some mission state. For now, this will have
# to do
@export var acid_rain: AcidRain

var _timer: SceneTreeTimer

func _enter_tree() -> void:
	# Running this in _enter_tree because we need to connect before the first
	# signal is emitted
	acid_rain.timer_changed.connect(_on_acid_rain_timer_changed)

func _ready() -> void:
	value = 0

func _process(_delta: float) -> void:
	if not _timer: return
	if acid_rain.enabled:
		ratio = _timer.time_left / max_value
	else:
		ratio = 1 - _timer.time_left / max_value

func _on_acid_rain_timer_changed(timer: SceneTreeTimer) -> void:
	_timer = timer
	max_value = timer.time_left
