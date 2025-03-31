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
@export var projectile: PackedScene
@export var effects: PackedScene
