class_name Chest extends StaticBody2D

@export var health_drop: PackedScene = preload("res://scenes/health_drop.tscn")
@export var health_drop_amount: float = 8.0

var _did_collect := false
var _velocity: Vector2

func _ready() -> void:
	$InteractArea.did_interact.connect(_collect)

func _physics_process(delta: float) -> void:
	_velocity.y += 9.81
	var collision := move_and_collide(_velocity * delta, false, 0.08, true)
	if collision != null:
		$CollisionShape2D.shape.get_rect().end = collision.get_position()

func _collect() -> void:
	if _did_collect:
		return
	
	var drop := health_drop.instantiate() as HealthDrop
	drop.heal_amount = health_drop_amount
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
	_did_collect = true
	# TODO: change this when we actually have a model
	$Sprite2D.flip_v = true
