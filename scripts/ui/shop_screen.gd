class_name ShopScreen extends Menu

var _shop: Shop
var _screen = null
var _shop_item_scene := preload("res://scenes/shop_item.tscn")

func _ready() -> void:
	super()
	
	$Return.pressed.connect(_on_quit_pressed)
	$Selection/Weapons.pressed.connect(_open_details_screen.bind(ScreenKind.WEAPONS))
	$Selection/Passives.pressed.connect(_open_details_screen.bind(ScreenKind.PASSIVES))
	$Selection/Gadgets.pressed.connect(_open_details_screen.bind(ScreenKind.GADGETS))
	$ItemsContainer/BackButton.pressed.connect(_on_back_button_pressed)
	_shop = HubManager.world.shop
	PersistentData.buckles_changed.connect(_update_buckles_label)
	_update_buckles_label()

enum ScreenKind {
	WEAPONS,
	PASSIVES,
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
			_show_item_details(_shop.weapons)
		ScreenKind.PASSIVES:
			_show_item_details(_shop.passives)
		ScreenKind.GADGETS:
			_show_item_details(_shop.gadgets)

func _on_inventory_item_buy(btn: Button, item: Shop.ShopItem) -> void:
	_shop.buy_gadget(item)
	if item.bought:
		_play_buy_sound()
		btn.disabled = true

func _on_alt_weapon_buy(btn: Button, item: Shop.ShopItem) -> void:
	_shop.buy_alt_weapon(item)
	if item.bought:
		_play_buy_sound()
		btn.disabled = true

func _on_passive_buy(btn: Button, item: Shop.ShopItem) -> void:
	_shop.buy_passive(item)
	if item.bought:
		_play_buy_sound()
		btn.disabled = true

func _show_item_details(items: Array[Shop.ShopItem]) -> void:
	for shop_item in items:
		var item = _shop_item_scene.instantiate()
		item.find_child("Icon").texture = shop_item.item.image
		item.find_child("Label").text = shop_item.item.name
		item.find_child("PriceLabel").text = str(shop_item.price)
		var btn = item.find_child("BuyButton")
		btn.disabled = shop_item.bought
		match _screen:
			ScreenKind.WEAPONS:
				btn.pressed.connect(_on_alt_weapon_buy.bind(btn, shop_item))
			ScreenKind.GADGETS:
				btn.pressed.connect(_on_inventory_item_buy.bind(btn, shop_item))
			ScreenKind.PASSIVES:
				btn.pressed.connect(_on_passive_buy.bind(btn, shop_item))
		$ItemsContainer/Items.add_child(item)

func _update_buckles_label() -> void:
	$BucklesLabel.text = "Buckles: " + str(PersistentData.buckles)

func _play_buy_sound() -> void:
	AudioManager.play_ui_sound(get_tree().current_scene, preload("res://assets/SoundEffects/buy_sound.wav"), -15)
