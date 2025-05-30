class_name Shop extends Interactable

class ShopItem:
	var item
	var price: int
	var bought: bool = false
	
	func _init(item_, price_: int) -> void:
		item = item_
		price = price_

var weapons: Array[ShopItem] = []
var gadgets: Array[ShopItem] = []
var passives: Array[ShopItem] = []

var _all_weapons: Array[ShopItem] = [
	ShopItem.new(preload("res://resources/rifle.tres"), 20),
	ShopItem.new(preload("res://resources/shotgun.tres"), 30),
	ShopItem.new(preload("res://resources/sniper.tres"), 30),
	ShopItem.new(preload("res://resources/grenade_launcher.tres"), 50),
	ShopItem.new(preload("res://resources/flamethrower.tres"), 50),
]
var _all_gadgets: Array[ShopItem] = [
	ShopItem.new(preload("res://resources/gadgets/grenade.tres"), 10),
	ShopItem.new(preload("res://resources/gadgets/health_potion.tres"), 10),
	ShopItem.new(preload("res://resources/gadgets/drone.tres"), 10),
]
var _all_passives: Array[ShopItem] = [
	ShopItem.new(preload("res://resources/passives/speed.tres"), 10),
	ShopItem.new(preload("res://resources/passives/double_jump.tres"), 10),
	ShopItem.new(preload("res://resources/passives/extra_health.tres"), 10),
	ShopItem.new(preload("res://resources/passives/fast_fall.tres"), 10),
	ShopItem.new(preload("res://resources/passives/burrow_boost.tres"), 10),
	ShopItem.new(preload("res://resources/passives/underground_stun.tres"), 10),
	ShopItem.new(preload("res://resources/passives/explosive_rounds.tres"), 10),
	ShopItem.new(preload("res://resources/passives/crit_chance.tres"), 10),
]

func _ready() -> void:
	weapons = _pick_many(_all_weapons, 2)
	gadgets = _pick_many(_all_gadgets, 1)
	passives = _pick_many(_all_passives, 3)
	
	did_interact.connect(_on_interact)

func buy_gadget(gadget: ShopItem) -> bool:
	if not _buy_item(gadget):
		return false
	
	PersistentData.gadget = gadget.item
	Player.Instance.gadget().set_gadget(gadget.item)
	return true

func buy_alt_weapon(weapon: ShopItem) -> bool:
	if not _buy_item(weapon):
		return false
	
	PersistentData.alternate = weapon.item
	Player.Instance.set_alt_weapon(weapon.item)
	return true

func buy_passive(passive: ShopItem) -> bool:
	if not _buy_item(passive):
		return false
	
	PersistentData.add_passive(passive.item)
	Player.Instance.add_passive(passive.item)
	return true

func _buy_item(item: ShopItem) -> bool:
	if PersistentData.buckles < item.price:
		return false
	
	PersistentData.buckles -= item.price
	item.bought = true
	return true

func _on_interact() -> void:
	HubManager.open_shop_screen()

func _pick_many(original: Array[ShopItem], amt: int) -> Array[ShopItem]:
	var copy := original.duplicate()
	copy.shuffle()
	return copy.slice(0, amt)
