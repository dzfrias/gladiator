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

signal buckles_changed

var _buckles: int
var _alternate: WeaponStats

func _ready() -> void:
	if not FileAccess.file_exists("user://savegame.json"):
		reset()
		return
	
	load_data()

func save() -> void:
	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var data := {
		"buckles": buckles,
		"alternate": alternate.serialize() if alternate != null else null,
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
		
		_buckles = json.data["buckles"]
		if json.data.has("alternate"):
			var alt = json.data["alternate"]
			_alternate = WeaponStats.deserialize(alt) if alt != null else null

func reset() -> void:
	_buckles = 100
	_alternate = null
	save()
