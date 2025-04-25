extends Control

@export var gadget_image: TextureRect

func _ready() -> void:
	Player.Instance.gadget_set.connect(_on_gadget_added)
	if Player.Instance.gadget() != null:
		gadget_image.texture = Player.Instance.gadget().image

func _on_gadget_added(gadget_info: GadgetInfo):
	if gadget_info != null:
		gadget_image.texture = gadget_info.image
