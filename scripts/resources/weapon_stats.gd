class_name WeaponStats extends Resource

enum AimMode {
	BIDIRECTIONAL,
	OMNIDIRECTIONAL,
}

@export var name: String
@export var reload_time: float = 1
@export var max_ammo: int = 8
@export var firing_interval: float = 0.5
@export var image: Texture
@export var aim_mode: AimMode = AimMode.BIDIRECTIONAL
@export_range(0.0, 1.0) var strength: float = 0.5
@export var projectile: PackedScene
@export var effects: PackedScene

func serialize() -> Dictionary:
	return {
		"name": name,
		"reload_time": reload_time,
		"max_ammo": max_ammo,
		"firing_interval": firing_interval,
		"image": image.resource_path,
		"aim_mode": int(aim_mode),
		"strength": strength,
		"projectile": projectile.resource_path,
		"effects": effects.resource_path if effects else null,
	}

static func deserialize(data: Dictionary) -> WeaponStats:
	var stats := WeaponStats.new()
	stats.name = data["name"]
	stats.reload_time = data["reload_time"]
	stats.max_ammo = data["max_ammo"]
	stats.firing_interval = data["firing_interval"]
	stats.image = load(data["image"])
	stats.aim_mode = data["aim_mode"]
	stats.strength = data["strength"]
	stats.projectile = load(data["projectile"])
	stats.effects = load(data["effects"]) if data["effects"] else null
	return stats
