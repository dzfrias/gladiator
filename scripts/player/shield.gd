class_name Shield extends StaticBody2D

@export var break_time: float = 4.0
@export var regen_time: float = 2.0
@export var regen_speed: float = 10
@export var buffer_time: float = 0.5

var _regen_timer = 0.0
var _can_enable = true

func _ready() -> void:
	$Health.died.connect(_on_died)
	$Health.damage_taken.connect(_on_damage_taken)

func _process(delta: float) -> void:
	if _regen_timer == 0.0 and $Health.health < $Health.max_health:
		$Health.heal(regen_speed * delta)
	_regen_timer = maxf(0.0, _regen_timer - delta)

func enable() -> void:
	if !_can_enable: return
	$CollisionShape2D.disabled = false

func disable() -> void:
	$CollisionShape2D.set_deferred("disabled", true)

func is_enabled() -> bool:
	return !$CollisionShape2D.disabled

func _on_died() -> void:
	_start_disabled_cooldown()

func _on_damage_taken(_amount: float, _direction: Vector2) -> void:
	_regen_timer = regen_time

func _start_disabled_cooldown() -> void:
	await get_tree().create_timer(buffer_time).timeout
	disable()
	_can_enable = false
	await get_tree().create_timer(break_time).timeout
	_can_enable = true
	$Health.restore()
	$HealthBarCreator.spawn()
