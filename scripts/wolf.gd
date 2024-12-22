extends CharacterBody2D


@export var speed: float = 300.0
var tracking: Node2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if tracking:
		var direction = sign(tracking.position.x - position.x)
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		tracking = body


func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		tracking = null


func _on_health_damage_taken(_amount: float) -> void:
	print("Wolf damage taken")


func _on_health_died() -> void:
	print("Wolf died")
	queue_free()
