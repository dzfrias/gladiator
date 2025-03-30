class_name Shop extends Area2D

var buckles: int:
	get: return _buckles
	set(amt):
		# TODO: we should have some sort of PersistentDataManager to store buckles along side
		# this in main memory. Then, the usage of this would be completely fluid.
		_buckles = amt
		buckles_changed.emit()

signal buckles_changed

var _buckles: int = 50

class ShopItem:
	var item
	var price: int
	var bought: bool = false
	
	func _init(item_, price_: int) -> void:
		item = item_
		price = price_

var weapons: Array[ShopItem] = [
	ShopItem.new(preload("res://resources/pistol.tres"), 10),
	ShopItem.new(preload("res://resources/rifle.tres"), 20),
	ShopItem.new(preload("res://resources/shotgun.tres"), 30),
	ShopItem.new(preload("res://resources/sniper.tres"), 30),
	ShopItem.new(preload("res://resources/grenade_launcher.tres"), 50),
]
var gadgets: Array[ShopItem] = [
	ShopItem.new(preload("res://resources/gadgets/grenade.tres"), 10),
	ShopItem.new(preload("res://resources/gadgets/health_potion.tres"), 10),
]

func _ready() -> void:
	$Interactable.did_interact.connect(_on_interact)

func buy_inventory_item(item: ShopItem) -> bool:
	if buckles < item.price:
		return false
	
	buckles -= item.price
	item.bought = true
	Player.Instance.inventory().add_item(item.item)
	return true

func buy_alt_weapon(weapon: ShopItem) -> bool:
	if buckles < weapon.price:
		return false
	
	buckles -= weapon.price
	weapon.bought = true
	Player.Instance.set_alt_weapon(weapon.item)
	
	return true

func _on_interact() -> void:
	HubManager.open_shop_screen()
