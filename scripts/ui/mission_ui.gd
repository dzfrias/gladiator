class_name MissionUI extends CanvasLayer

@export var lightning_scene: PackedScene
@export var acid_rain_scene: PackedScene

func _ready() -> void:
	var indicator: Node
	if MissionManager.weather is AcidRain:
		indicator = acid_rain_scene.instantiate()
		indicator.acid_rain = MissionManager.weather
	if MissionManager.weather is Lightning:
		indicator = lightning_scene.instantiate()
		indicator.lightning = MissionManager.weather
	if indicator != null:
		add_child(indicator)
