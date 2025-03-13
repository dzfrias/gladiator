extends RichTextLabel

var weapon

var infinite_ammo_text = "Ammo:  [img=8,8]assets/infinity_sign.png[/img]"

func _ready() -> void:
	var item = Player.Instance.get_current_item()
	if item is Weapon:
		weapon = item as Weapon
		if weapon.weapon_stats.max_ammo == -1:
			text = infinite_ammo_text
		else:
			text = "Ammo: " + str(weapon.ammo) + "/" + str(weapon.weapon_stats.max_ammo)
		weapon.on_ammo_changed.connect(_on_ammo_changed)
	else:
		hide()
	Player.Instance.inventory.on_item_switched.connect(_on_item_switched)

func _on_item_switched(current_item):
	if current_item is Weapon:
		show()
		if weapon:
			weapon.on_ammo_changed.disconnect(_on_ammo_changed)
		weapon = current_item as Weapon
		if weapon.weapon_stats.max_ammo == -1:
			text = infinite_ammo_text
		else:
			text = "Ammo: " + str(weapon.ammo) + "/" + str(weapon.weapon_stats.max_ammo)
		weapon.on_ammo_changed.connect(_on_ammo_changed)
	else:
		if weapon:
			weapon.on_ammo_changed.disconnect(_on_ammo_changed)
		weapon = null
		hide()

func _on_ammo_changed(ammo: int, max_ammo: int) -> void:
	if weapon.weapon_stats.max_ammo == -1:
		text = infinite_ammo_text
	else:
		text = "Ammo: " + str(weapon.ammo) + "/" + str(weapon.weapon_stats.max_ammo)
