extends Control

@export var gadget_image: TextureRect
@export var uses_num: RichTextLabel

func _ready() -> void:
	var player_gadget = Player.Instance.gadget()
	player_gadget.gadget_set.connect(_on_gadget_added)
	player_gadget.uses_changed.connect(_on_gadget_uses_changed)
	if player_gadget.gadget_info != null:
		gadget_image.texture = player_gadget.gadget_info.image

func _on_gadget_added(gadget_info: GadgetInfo):
	if gadget_info != null:
		gadget_image.texture = gadget_info.image
		uses_num.text = str(Player.Instance.gadget().gadget_info.max_uses)

func _on_gadget_uses_changed(uses_remaining):
	uses_num.text = str(uses_remaining)
