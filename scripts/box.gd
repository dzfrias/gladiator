extends RigidBody2D

@export var health : Health

func _ready() -> void:
	health.damage_taken.connect(_on_damage_taken)
	health.died.connect(_on_died)
	
func _on_damage_taken(amount: float):
	print("Ow")

func _on_died():
	print("Im dead now")
	queue_free()
