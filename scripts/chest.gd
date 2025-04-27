class_name Chest extends StaticBody2D

@export var health_drop_amount: float = 8.0
@export var max_y_velocity: float = 800.0

var _health_drop: PackedScene = preload("res://scenes/health_drop.tscn")
var _ammo_drop: PackedScene = preload("res://scenes/ammo_collectable.tscn")
var _gadget_drop: PackedScene = preload("res://scenes/gadget_collectable.tscn")

@onready var _original_material: Material = $Sprite2D.material
var _white_material: Material = preload("res://resources/materials/white_material.tres")

var _did_collect := false
var _velocity: Vector2

func _ready() -> void:
	$InteractArea.did_interact.connect(_collect)

func _physics_process(delta: float) -> void:
	_velocity.y = minf(_velocity.y + 981 * delta, max_y_velocity)
	var collision := move_and_collide(_velocity * delta, false, 0.08, true)
	if collision != null:
		$CollisionShape2D.shape.get_rect().end = collision.get_position()

func _collect() -> void:
	if _did_collect:
		return
	
	_did_collect = true
	await _flash()
	
	var drop := _choose_drop()
	get_tree().current_scene.add_child(drop)
	drop.global_position = global_position
	
	# TODO: change this when we actually have a model
	$Sprite2D.flip_v = true
	$GodRays.queue_free()

func _choose_drop() -> Node2D:
	var drops: Array[PackedScene] = []
	if Player.Instance.gadget().gadget_info != null:
		drops.append(_gadget_drop)
	if Player.Instance.alt_weapon() != null:
		drops.append(_ammo_drop)
	drops.append(_health_drop)
	
	var drop_scene := drops[randi_range(0, drops.size() - 1)]
	var drop := drop_scene.instantiate()
	
	if drop is HealthDrop:
		drop.heal_amount = health_drop_amount
	
	return drop
	
func _flash() -> void:
	$Sprite2D.material = _white_material
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material = _original_material
