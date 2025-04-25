class_name GadgetInfo extends Resource

@export var name: String
@export var image: Texture
@export var scene: PackedScene

func serialize() -> Dictionary:
	return {
		"name": name,
		"image": image.resource_path,
		"scene": scene
	}

static func deserialize(data: Dictionary) -> GadgetInfo:
	var stats := GadgetInfo.new()
	stats.name = data["name"]
	stats.image = load(data["image"])
	stats.scene = load(data["scene"])
	return stats
