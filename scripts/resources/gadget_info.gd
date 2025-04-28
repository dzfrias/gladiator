class_name GadgetInfo extends Resource

@export var name: String
@export var image: Texture
@export var scene: PackedScene
@export var max_uses: int = 3

func serialize() -> Dictionary:
	return {
		"name": name,
		"image": image.resource_path,
		"scene": scene.resource_path,
		"max_uses": max_uses
	}

static func deserialize(data: Dictionary) -> GadgetInfo:
	var stats := GadgetInfo.new()
	stats.name = data["name"]
	stats.image = load(data["image"])
	stats.scene = load(data["scene"])
	stats.max_uses = data["max_uses"]
	return stats
