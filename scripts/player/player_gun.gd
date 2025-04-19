class_name PlayerGun extends Sprite2D

@export var run_offset: Vector2 = Vector2(-5, 2)
@export var run_frames: Array[int] = [2, 6]
@export var shoot_rotation: float = PI / 6
@export var shoot_recovery_speed: float = 0.2

var _player: Player
@onready var _original_x: float = position.x
@onready var _original_y: float = position.y

func _ready() -> void:
	_player = get_parent() as Player
	_player.on_weapon_switch.connect(_on_weapon_switched)
	_player.main_weapon().fired.connect(_on_weapon_fired)
	# _player.alt_weapon().fired.connect(_on_weapon_fired)

func _process(_delta: float) -> void:
	var p := run_offset if run_frames.has(_player.sprite().frame) else Vector2.ZERO
	p.x *= _player.direction().scalar
	position.x = _original_x * _player.direction().scalar
	position.y = _original_y
	position += p
	flip_h = not _player.direction().is_right
	visible = _player.sprite().visible

func _on_weapon_switched() -> void:
	texture = _player.selected_weapon.weapon_stats.image

func _on_weapon_fired() -> void:
	rotation = shoot_rotation * -_player.direction().scalar
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", 0.0, shoot_recovery_speed)
