class_name FreeOnFinish extends CPUParticles2D

@export var to_free: Node

func _ready() -> void:
	await get_tree().process_frame
	emitting = true
	await finished
	to_free.queue_free()
