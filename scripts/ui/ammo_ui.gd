extends Control

@onready var weapon: Weapon = Player.Instance.weapon()

@export var weapon_image: TextureRect
@export var alt_weapon_image: TextureRect
@export var infinite_ammo_image: TextureRect
@export var ammo_text: RichTextLabel

func _ready() -> void:
	var item = Player.Instance.inventory().get_held_item()
	Player.Instance.alt_weapon_set.connect(_alt_weapon_set)
	if item == Player.WEAPON_INDICATOR:
		if weapon.weapon_stats.max_ammo == -1:
			show_infinite_ammo_image()
		else:
			show_ammo_text()
		weapon.on_ammo_changed.connect(_on_ammo_changed)
	else:
		hide()
	Player.Instance.inventory().on_item_switched.connect(_on_item_switched)
	Player.Instance.on_weapon_switch.connect(_on_weapon_switched)

func _on_item_switched(current_item):
	if typeof(current_item) == TYPE_STRING and current_item == Player.WEAPON_INDICATOR:
		show()
		if weapon:
			weapon.on_ammo_changed.disconnect(_on_ammo_changed)
		if weapon.weapon_stats.max_ammo == -1:
			show_infinite_ammo_image()
		else:
			show_ammo_text()
		weapon.on_ammo_changed.connect(_on_ammo_changed)
	else:
		weapon.on_ammo_changed.disconnect(_on_ammo_changed)
		hide()

func _on_weapon_switched():
	weapon.on_ammo_changed.disconnect(_on_ammo_changed)
	
	if Player.Instance.alt_weapon().weapon_stats != null:
		alt_weapon_image.texture = weapon.weapon_stats.image
	
	weapon = Player.Instance.weapon()
	weapon.on_ammo_changed.connect(_on_ammo_changed)
	if weapon.weapon_stats.image != null:
		weapon_image.texture = weapon.weapon_stats.image
	
	if weapon.weapon_stats.max_ammo == -1:
		show_infinite_ammo_image()
	else:
		show_ammo_text()

func _alt_weapon_set(weapon_stats):
	alt_weapon_image.texture = weapon_stats.image

func _on_ammo_changed(_ammo: int, max_ammo: int) -> void:
	if weapon.weapon_stats.max_ammo == -1:
		show_infinite_ammo_image()
	else:
		show_ammo_text()

func show_ammo_text():
	ammo_text.show()
	infinite_ammo_image.hide()
	ammo_text.text = str(weapon.ammo)

func show_infinite_ammo_image():
	ammo_text.hide()
	infinite_ammo_image.show()
	
