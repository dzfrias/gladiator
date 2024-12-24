class_name LightningIndicator extends ProgressBar

@export var lightning: Lightning

func _ready() -> void:
	value = 0
	max_value = lightning.tolerance_time

func _process(_delta: float) -> void:
	value = lightning.current_time
