extends Label

var weapon

func _ready() -> void:
	var item = Player.Instance.get_current_item()
	if item is Weapon:
		weapon = item as Weapon
		text = "Ammo: " + str(weapon.ammo) + "/" + str(weapon.weapon_stats.max_ammo)
		weapon.on_ammo_changed.connect(_on_ammo_changed)
	else:
		hide()
	Player.Instance.on_item_switched.connect(_on_item_switched)

func _on_item_switched(current_item):
	print('test')
	if current_item is Weapon:
		show()
		if weapon:
			weapon.on_ammo_changed.disconnect(_on_ammo_changed)
		weapon = current_item as Weapon
		text = "Ammo: " + str(weapon.ammo) + "/" + str(weapon.weapon_stats.max_ammo)
		weapon.on_ammo_changed.connect(_on_ammo_changed)
	else:
		if weapon:
			weapon.on_ammo_changed.disconnect(_on_ammo_changed)
		weapon = null
		print("HIDE")
		hide()

func _on_ammo_changed(ammo: int, max_ammo: int) -> void:
	text = "Ammo: " + str(ammo) + "/" + str(max_ammo)
