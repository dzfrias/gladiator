class_name PlayerGun extends GunOverlay

var _player: Player

func _ready() -> void:
	super()
	_player = get_parent() as Player
	_player.on_weapon_switch.connect(_on_weapon_switched)

func _on_weapon_switched() -> void:
	texture = _player.selected_weapon.weapon_stats.image
