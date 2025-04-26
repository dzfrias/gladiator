class_name Chest extends StaticBody2D

@export var health_drop_amount: float = 8.0
@export var max_y_velocity: float = 800.0
@export var drop_amount: int = 2

class ChestDrop:
	var scene: PackedScene
	var chance: float
	
	func _init(scene, chance) -> void:
		assert(chance >= 0 and chance <= 1)
		
		self.scene = load(scene)
		self.chance = chance

var drops := [
	ChestDrop.new("res://scenes/health_drop.tscn", 0.3),
	ChestDrop.new("res://scenes/ammo_collectable.tscn", 0.3),
	ChestDrop.new("res://scenes/gadget_collectable.tscn", 0.4)
]

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
	
	for i in range(drop_amount):
		var drop = _choose_random_drop()
		
		if drop.scene is HealthDrop:
			drop.heal_amount = health_drop_amount
		
		var drop_instance = drop.scene.instantiate()
		drop_instance.global_position = global_position
		get_tree().current_scene.add_child(drop_instance)
	# TODO: change this when we actually have a model
	$Sprite2D.flip_v = true
	$GodRays.queue_free()

func _choose_random_drop() -> ChestDrop:
	var random_num = randf_range(0, 1)
	var total_chance = 0
	var final_drop: ChestDrop
	for drop in drops:
		if random_num > total_chance and random_num <= total_chance + drop.chance:
			final_drop = drop
		total_chance += drop.chance
	assert(total_chance == 1)
	return final_drop

func _flash() -> void:
	$Sprite2D.material = _white_material
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material = _original_material
