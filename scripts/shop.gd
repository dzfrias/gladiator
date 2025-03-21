class_name Shop extends Area2D

var buckles: float:
	get: return _buckles
	set(amt):
		_buckles = amt
		buckles_changed.emit()

signal buckles_changed

var _buckles: int = 50

class WeaponItem:
	var stats: WeaponStats
	var price: int
	var bought: bool = false
	
	func _init(stats: WeaponStats, price: int) -> void:
		self.stats = stats
		self.price = price

var weapons: Array[WeaponItem] = [
	WeaponItem.new(preload("res://resources/pistol.tres"), 10),
	WeaponItem.new(preload("res://resources/rifle.tres"), 20),
	WeaponItem.new(preload("res://resources/shotgun.tres"), 30),
	WeaponItem.new(preload("res://resources/sniper.tres"), 30)
]

func _ready() -> void:
	$Interactable.did_interact.connect(_on_interact)

func buy_weapon(weapon: WeaponItem) -> bool:
	if buckles < weapon.price:
		return false
	
	buckles -= weapon.price
	weapon.bought = true
	Player.Instance._items.append(weapon)
	return true

func _on_interact() -> void:
	HubManager.open_shop_screen()
