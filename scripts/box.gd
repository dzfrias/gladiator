extends RigidBody2D

func _ready() -> void:
	$Health.damage_taken.connect(_on_health_damage_taken)
	$Health.died.connect(_on_health_died)

func _on_health_damage_taken(_amount: float) -> void:
	print("Ow")

func _on_health_died() -> void:
	print("Im dead now")
	queue_free()
