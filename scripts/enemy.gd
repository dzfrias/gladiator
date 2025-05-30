class_name Enemy extends CharacterBody2D

@export var notify_depth = 2
@export var hit_sound_interval: float = 0.5

var stunned: bool

var _sprites: Array[CanvasItem]
var _white_material = preload("res://resources/materials/white_material.tres")
var _can_play_sound: bool = true

signal hit_floor
signal got_stunned

func _ready() -> void:
	$DetectionZone.body_entered.connect(_on_detection_zone_body_entered)
	$Health.died.connect(_on_health_died)
	$Health.damage_taken.connect(_on_health_damage_taken)
	
	for child in get_children():
		if child is AnimatedSprite2D or child is Sprite2D:
			_sprites.append(child)

func move() -> void:
	var prev_velocity := velocity
	if stunned:
		velocity = Vector2.ZERO
	
	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		hit_floor.emit()
	
	if stunned:
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
	await set_stunned(duration)
	collision_layer = previous_layer

func health() -> Health:
	return $Health

func set_stunned(duration: float) -> void:
	if stunned:
		return
	var original_materials: Array[Material] = []
	for sprite in _sprites:
		original_materials.append(sprite.material)
		sprite.material = _white_material
	stunned = true
	got_stunned.emit()
	await get_tree().create_timer(duration).timeout
	stunned = false
	for i in range(_sprites.size()):
		_sprites[i].material = original_materials[i]

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		notify(notify_depth)

func _on_health_damage_taken(_amount: float, _direction: Vector2) -> void:
	notify(notify_depth)
	set_stunned(0.1)
	if _can_play_sound:
		AudioManager.play_sound(self, preload("res://assets/SoundEffects/hit.wav"))
		_start_sound_timer()

func _on_health_died() -> void:
	queue_free()

func _start_sound_timer() -> void:
	_can_play_sound = false
	await get_tree().create_timer(hit_sound_interval).timeout
	_can_play_sound = true
