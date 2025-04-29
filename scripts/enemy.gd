class_name Enemy extends CharacterBody2D

@export var notify_depth = 2

var _stunned: bool

signal hit_floor

func _ready() -> void:
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)

func move() -> void:
	var prev_velocity := velocity
	if _stunned:
		velocity = Vector2.ZERO
	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		hit_floor.emit()
	if _stunned:
		# Restore old velocity
		velocity = prev_velocity

func notify(depth: int = 0) -> void:
	if depth == 0:
		return
	for body in $NotifyZone.get_overlapping_bodies():
		if body is Enemy:
			body.notify(depth - 1)

func spawn_in(duration: float) -> void:
	var previous_layer := collision_layer
	collision_layer = Constants.INVINCIBLE_LAYER
	_stunned = true
	await get_tree().create_timer(duration).timeout
	_stunned = false
	collision_layer = previous_layer

func health() -> Health:
	return $Health

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		notify(notify_depth)

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	notify(notify_depth)
	_stunned = true
	await get_tree().create_timer(0.1).timeout
	_stunned = false

func _on_health_died() -> void:
	queue_free()
