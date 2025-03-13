class_name Gadget extends Node

var prefab: PackedScene
var type: GadgetType

enum GadgetType {
	THROWABLE,
	ACTIVATABLE
}

func init(prefab: PackedScene, type: GadgetType):
	self.prefab = prefab
	self.type = type

func use(player: Player, position: Vector2, direction: Direction):
	if type == GadgetType.THROWABLE:
		throw(player, position, direction)
	elif type == GadgetType.ACTIVATABLE:
		prefab.get_script().activate()


func throw(player: Player, position: Vector2, direction: Direction):
	var throwable = prefab.instantiate()
	throwable.global_position = position
	player.get_tree().current_scene.add_child(throwable)
	throwable.apply_force(Vector2(direction.scalar * 12000, -12000))
	print("Throw")
