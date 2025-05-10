extends HBoxContainer

func _ready() -> void:
	Player.Instance.passive_added.connect(_on_passive_added)

func _on_passive_added(passive: Passive):
	print("passive added")
	var texture = TextureRect.new()
	texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	texture.texture = passive.image
	add_child(texture)
