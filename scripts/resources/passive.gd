class_name Passive extends Resource

@export var name: String
@export var image: Texture
@export var scene: PackedScene

func serialize() -> Dictionary:
	return {
		"name": name,
		"image": image.resource_path,
		"scene": scene.resource_path,
	}

static func deserialize(data: Dictionary) -> Passive:
	var stats := Passive.new()
	stats.name = data["name"]
	stats.image = load(data["image"])
	stats.scene = load(data["scene"])
	return stats
