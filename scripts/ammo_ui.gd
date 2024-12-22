extends Label

func _ready() -> void:
	var weapon = Player.Instance.get_weapon() as Weapon
	text = "Ammo: " + str(weapon.ammo) + "/" + str(weapon.max_ammo)
	weapon.on_ammo_changed.connect(on_ammo_changed)

func on_ammo_changed(ammo: int, max_ammo: int):
	text = "Ammo: " + str(ammo) + "/" + str(max_ammo)
