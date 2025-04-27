class_name ConquerMission extends Mission

var enemies_remaining: int

func _ready() -> void:
	super()
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	if node.is_in_group("enemy"):
		enemies_remaining += 1
		for child in node.get_children():
			if child is Health:
				child.died.connect(_on_enemy_death)

func _on_enemy_death() -> void:
	enemies_remaining -= 1
	if enemies_remaining <= 0 and not in_combat:
		mission_finished.emit()
