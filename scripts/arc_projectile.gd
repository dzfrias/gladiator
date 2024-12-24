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

func _on_body_entered(body: Node2D) -> void:
	var collider := body as CollisionObject2D
	if body is Player:
		var player := body as Player
		player.damage(damage)
		queue_free()
		return
	if collider.collision_layer & Constants.ENVIRONMENT_LAYER:
		Debug.draw_circle(position, splash_radius)
		var space_state := get_world_2d().direct_space_state
		var splash := CircleShape2D.new()
		splash.radius = splash_radius
		var splash_transform = Transform2D(0, position)
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = splash
		query.transform = splash_transform
		query.collision_mask = Constants.ENTITY_LAYER
		var collisions = space_state.intersect_shape(query)
		for collision in collisions:
			var entity = collision.get("collider")
			if entity is Player:
				var player = entity as Player
				player.damage(damage)
		queue_free()
