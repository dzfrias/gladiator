class_name FreeOnFinish extends CPUParticles2D

@export var to_free: Node

func _ready() -> void:
	await finished
	to_free.queue_free()
