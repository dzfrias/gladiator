class_name GunOverlay extends Sprite2D

@export var run_offset: Vector2 = Vector2(-5, 2)
@export var run_frames: Array[int] = []
@export var shoot_rotation: float = PI / 6
@export var shoot_recovery_speed: float = 0.2

var _weapon: Weapon
var _direction: Direction
var _sprite: AnimatedSprite2D
@onready var _original_pos: Vector2 = position

func _ready() -> void:
	for child in get_parent().get_children():
		if child is Weapon and child.weapon_stats != null:
			_weapon = child
		if child is Direction:
			_direction = child
		if child is AnimatedSprite2D:
			_sprite = child
	
	assert(_weapon != null)
	texture = _weapon.weapon_stats.image
	_weapon.fired.connect(_on_weapon_fired)

func _process(_delta: float) -> void:
	var p := run_offset if run_frames.has(_sprite.frame) else Vector2.ZERO
	p.x *= _direction.scalar
	position.x = _original_pos.x * _direction.scalar
	position.y = _original_pos.y
	position += p
	flip_h = not _direction.is_right
	visible = _sprite.visible

func _on_weapon_fired(_projectile: Node2D) -> void:
	rotation = shoot_rotation * -_direction.scalar
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", 0.0, shoot_recovery_speed)
