extends Label

func _ready() -> void:
	var weapon = Player.Instance.get_weapon() as Weapon
	text = "Ammo: " + str(weapon.ammo) + "/" + str(weapon.weapon_stats.max_ammo)
	weapon.on_ammo_changed.connect(_on_ammo_changed)
	Player.Instance.weapon_changed.connect(_on_weapon_changed)

func _on_ammo_changed(ammo: int, max_ammo: int) -> void:
	text = "Ammo: " + str(ammo) + "/" + str(max_ammo)

func _on_weapon_changed() -> void:
	# TODO this needs to be much more robust when we add the ability to change
	# between weapons. Right now, since there's only one weapon and the only thing
	# the player can do is equip/unequip it, this will do.
	visible = Player.Instance.get_weapon() != null
