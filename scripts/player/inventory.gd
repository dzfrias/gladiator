class_name Inventory extends Node

signal on_item_switched(current_item)

var _current_item: Variant
var items: Array

func add_item(item):
	items.append(item)
	if items.size() == 1:
		_current_item = item
		on_item_switched.emit(_current_item)

func set_held_item(index: int):
	_current_item = items[index]
	on_item_switched.emit(_current_item)

func get_held_item():
	return _current_item
