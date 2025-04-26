extends Node2D

signal gadget_set(gadget_info)
signal uses_changed(uses_remaining)

var gadget_info: GadgetInfo
var uses_remaining = 0

func use():
	if uses_remaining <= 0:
		return
	
	var gadget = gadget_info.scene.instantiate()
	gadget.init($Direction)
	gadget.global_position = get_node("../ItemPosition").global_position
	get_tree().current_scene.add_child(gadget)
	uses_remaining -= 1
	uses_changed.emit(uses_remaining)

func set_gadget(gadget: GadgetInfo):
	if gadget:
		gadget_info = gadget
		uses_remaining = gadget.max_uses
		gadget_set.emit(gadget)

func add_use():
	uses_remaining += 1
	uses_changed.emit(uses_remaining)
