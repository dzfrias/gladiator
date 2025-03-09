class_name Shield extends StaticBody2D

@export var cooldown_time: float = 8.0

var _can_enable = true

func _ready() -> void:
	$Health.died.connect(_on_died)

func enable() -> void:
	if !_can_enable: return
	$CollisionShape2D.disabled = false

func disable() -> void:
	$CollisionShape2D.set_deferred("disabled", true)

func is_enabled() -> bool:
	return !$CollisionShape2D.disabled

func _on_died() -> void:
	_start_disabled_cooldown()

func _start_disabled_cooldown() -> void:
	disable()
	_can_enable = false
	await get_tree().create_timer(8).timeout
	_can_enable = true
	$Health.restore()
	$HealthBarCreator.spawn()
