extends Label

var player: Player

func _ready() -> void:
	player = Player.Instance

func _process(delta: float) -> void:
	text = "Coords: (%s)" % [player.position.round()]
