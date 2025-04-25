extends RayCast2D

@export var move_amount_min: float = 2.0
@export var move_amount_max: float = 10.0
@export var droplet_spawn_inteval: float = 0.01
@export var droplet_scene: PackedScene = preload("res://scenes/particles/droplet.tscn")

var _points: Array[Vector2] = []

signal computed

func _ready() -> void:
	global_position.y = -5000.0
	_spawn_droplets()

func set_bounds(left: float, right: float) -> void:
	_compute(left, right)

func _compute(left: float, right: float) -> void:
	assert(left < right)
	
	global_position.x = left
	while global_position.x <= right:
		_points.append(get_collision_point())
		global_position.x += randf_range(move_amount_min, move_amount_max)
		force_raycast_update()
	computed.emit()

func _spawn_droplets() -> void:
	while true:
		if _points.size() == 0:
			await computed
		var point := _points[randi_range(0, _points.size() - 1)]
		var droplet := droplet_scene.instantiate() as CPUParticles2D
		get_tree().current_scene.add_child(droplet)
		droplet.emitting = true
		droplet.global_position = point
		await get_tree().create_timer(droplet_spawn_inteval).timeout
