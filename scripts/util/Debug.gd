extends Node

func draw_circle(position: Vector2, radius: float, color := Color.RED, duration := 0.1):
	var on_draw = func(node: Node2D) -> void:
		node.draw_circle(position, radius, color)
	await _internal_draw(on_draw, duration)

func draw_line(p1: Vector2, p2: Vector2, width := 10.0, color := Color.RED, duration := 0.1):
	var on_draw = func(node: Node2D) -> void:
		node.draw_line(p1, p2, color, width)
	await _internal_draw(on_draw, duration)

func _internal_draw(on_draw, duration: float) -> void:
	var node = Node2D.new()
	var curried_draw = func() -> void:
		on_draw.call(node)
	node.draw.connect(curried_draw)
	get_tree().current_scene.add_child(node)
	await get_tree().create_timer(duration).timeout
	if node:
		node.queue_free()
