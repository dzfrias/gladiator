extends Node

@export var chance: float = 0.25
@export var multiplier: float = 1.5

func _ready() -> void:
	await get_tree().process_frame
	Player.Instance.weapon().fired.connect(_on_weapon_fired)
	Player.Instance.alt_weapon_node().fired.connect(_on_weapon_fired)

func _on_weapon_fired(projectile: Node2D) -> void:
	if randf() > chance:
		return
	
	projectile.hit.connect(_crit.bind(projectile))

func _crit(projectile) -> void:
	projectile.damage *= multiplier
