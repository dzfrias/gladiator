class_name UndergroundStun extends Area2D

@export var stun_duration: float = 0.9

func _ready() -> void:
	await get_tree().process_frame
	Player.Instance.exited_underground.connect(_on_exited_underground)

func _on_exited_underground() -> void:
	if Player.Instance.velocity.y == 0:
		return
	$Particles.emitting = true
	for body in get_overlapping_bodies():
		if body is Enemy:
			body.set_stunned(stun_duration)
