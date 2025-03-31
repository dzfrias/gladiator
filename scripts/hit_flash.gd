class_name HitFlash extends Timer

@export var health: Health
@export var canvas_item: CanvasItem

var _original_material: Material
var _white_material: Material = preload("res://resources/materials/white_material.tres")

func _ready() -> void:
	if health == null:
		health = $"../Health"
	if canvas_item == null:
		if has_node("../Sprite2D"):
			canvas_item = $"../Sprite2D"
		elif has_node("../AnimatedSprite2D"):
			canvas_item = $"../AnimatedSprite2D"
		else:
			assert(false)
	
	health.damage_taken.connect(_on_damage_taken)
	_original_material = canvas_item.material

func _on_damage_taken(_amt: float, _direction: Vector2) -> void:
	if not is_stopped():
		# Continue running the timer if already running
		start()
		return
	canvas_item.material = _white_material
	start()
	await timeout
	canvas_item.material = _original_material
