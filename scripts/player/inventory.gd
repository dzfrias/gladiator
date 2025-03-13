class_name Inventory extends Node

signal on_item_switched(current_item)

var _current_item
var _items: Array

func _init() -> void:
	_current_item = null

func add_item(item):
	_items.append(item)
	if _items.size() == 1:
		_current_item = item

func set_held_item(index: int):
	_current_item = _items[index]
	on_item_switched.emit(_current_item)
	print(_items[index])

func get_held_item():
	return _current_item

func get_size():
	return _items.size()
