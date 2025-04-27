extends Area2D

@export var text_wait_time: float = 1.0
@export var wait_time: float = 1.5
@export var enemy_to_spawn: PackedScene

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is not Player:
		return
	
	_start.call_deferred()

func _start() -> void:
	monitoring = false
	Player.Instance.camera().add_trauma(0.7)
	await get_tree().create_timer(wait_time).timeout
	_make_text_appear()
	for _i in range(50):
		var spawn_point = $Spawn1 if randf() <= 0.5 else $Spawn2
		var enemy := enemy_to_spawn.instantiate() as Node2D
		get_tree().current_scene.add_child(enemy)
		enemy.notify(0)
		enemy.global_position = spawn_point.global_position
		await get_tree().create_timer(0.05).timeout

func _make_text_appear() -> void:
	await get_tree().create_timer(text_wait_time).timeout
	$Text.visible = true
	$Text2.visible = true
	$Text3.visible = true
