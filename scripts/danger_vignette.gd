extends ColorRect

@export var cutoff: float = 5.0

func _process(_delta: float) -> void:
	visible = Player.Instance.get_health().health <= cutoff
