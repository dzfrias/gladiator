class_name ShopScreen extends CanvasLayer

var _shop: Shop
var _screen = null
var _shop_item_scene := preload("res://scenes/shop_item.tscn")

func _ready() -> void:
	$Return.pressed.connect(_on_quit_pressed)
	$Selection/Weapons.pressed.connect(_open_details_screen.bind(ScreenKind.WEAPONS))
	$Selection/Armor.pressed.connect(_open_details_screen.bind(ScreenKind.ARMOR))
	$Selection/Gadgets.pressed.connect(_open_details_screen.bind(ScreenKind.GADGETS))
	$ItemsContainer/BackButton.pressed.connect(_on_back_button_pressed)
	_shop = HubManager.world.shop
	_shop.buckles_changed.connect(_update_buckles_label)
	_update_buckles_label()

enum ScreenKind {
	WEAPONS,
	ARMOR,
	GADGETS,
}

func _on_quit_pressed() -> void:
	HubManager.return_to_world()

func _on_back_button_pressed() -> void:
	$Selection.visible = true
	$ItemsContainer.visible = false
	for child in $ItemsContainer/Items.get_children():
		$ItemsContainer/Items.remove_child(child)
	_screen = null

func _open_details_screen(kind: ScreenKind) -> void:
	$Selection.visible = false
	$ItemsContainer.visible = true
	_screen = kind
	match kind:
		ScreenKind.WEAPONS:
			for weapon in _shop.weapons:
				var item = _shop_item_scene.instantiate()
				item.find_child("Label").text = weapon.stats.name
				item.find_child("PriceLabel").text = str(weapon.price)
				var btn = item.find_child("BuyButton")
				btn.pressed.connect(_on_weapon_buy.bind(btn, weapon))
				$ItemsContainer/Items.add_child(item)

func _on_weapon_buy(btn: Button, weapon: Shop.WeaponItem) -> void:
	_shop.buy_weapon(weapon)
	if weapon.bought:
		btn.disabled = true

func _update_buckles_label() -> void:
	$BucklesLabel.text = "Buckles: " + str(_shop.buckles)
