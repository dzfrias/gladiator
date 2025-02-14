class_name ArcProjectile extends Area2D

var velocity: Vector2
var damage := 5.0
var splash_radius := 90.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func fire(speed: float, angle: float):
	assert(speed >= 0)
	velocity = Vector2.RIGHT.rotated(angle) * speed

func _process(delta: float) -> void:
	velocity.y += 980 * delta
	position += velocity * delta

func _on_body_entered(_body: Node2D) -> void:
	Debug.draw_circle(position, splash_radius)
	var space_state := get_world_2d().direct_space_state
	var splash := CircleShape2D.new()
	splash.radius = splash_radius
	var splash_transform := Transform2D(0, position)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = splash
	query.transform = splash_transform
	query.collision_mask = Constants.PLAYER_LAYER
	var collisions := space_state.intersect_shape(query)
	assert(collisions.size() <= 1)
	if collisions.size() == 1:
		var collider = collisions[0].get("collider")
		var body := collider as Node2D
		for child in body.get_children():
			if child is Health:
				var health := child as Health
				health.take_damage(damage, Vector2.ZERO)
	queue_free()
