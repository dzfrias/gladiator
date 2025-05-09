extends Node

var buckles: int:
	get: return _buckles
	set(amt):
		_buckles = amt
		buckles_changed.emit()
		save()
var alternate: WeaponStats:
	get: return _alternate
	set(alt):
		_alternate = alt
		save()
var gadget: GadgetInfo:
	get: return _gadget
	set(gadget):
		_gadget = gadget
		save()
var level: int:
	get: return _level
	set(level):
		_level = level
		save()

signal buckles_changed

var _passives: Array = []
var _buckles: int
var _alternate: WeaponStats
var _gadget: GadgetInfo
var _level: int

func _ready() -> void:
	if not FileAccess.file_exists("user://savegame.json"):
		reset()
		return
	
	load_data()

func add_passive(passive: Passive) -> void:
	_passives.append(passive)
	save()

func get_passives() -> Array:
	return _passives

func save() -> void:
	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var data := {
		"buckles": buckles,
		"alternate": alternate.serialize() if alternate != null else null,
		"gadget": gadget.serialize() if gadget != null else null,
		"passives": _passives.map(func(passive): return passive.serialize()),
		"level": level,
	}
	file.store_line(JSON.stringify(data))

func load_data() -> void:
	var file := FileAccess.open("user://savegame.json", FileAccess.READ)
	var length := file.get_length()
	while file.get_position() < length:
		var json_string := file.get_line()
		var json := JSON.new()
		
		var parse_result := json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		if not json.data.has_all(["buckles", "alternate", "gadget", "passives", "level"]):
			print("Not enough JSON information, missing some keys... resetting")
			reset()
			return
		
		_buckles = json.data["buckles"]
		_alternate = WeaponStats.deserialize(json.data["alternate"]) if json.data["alternate"] != null else null
		_gadget = GadgetInfo.deserialize(json.data["gadget"]) if json.data["gadget"] != null else null
		_passives = json.data["passives"].map(func(passive_dict): return Passive.deserialize(passive_dict))
		_level = json.data["level"]

func reset() -> void:
	_buckles = 10
	_alternate = null
	_gadget = null
	_passives = []
	_level = 0
	save()
