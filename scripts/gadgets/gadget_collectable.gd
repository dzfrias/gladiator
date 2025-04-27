class_name GadgetCollectable extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var player := Player.Instance as Player
	var gadget := player.gadget()
	gadget.gadget_set.connect(_change_sprite)
	if gadget.gadget_info != null:
		_change_sprite(gadget.gadget_info)

func _change_sprite(gadget: GadgetInfo) -> void:
	$TextureRect.texture = gadget.image

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is not Player:
		return
	
	queue_free()
	var player := body as Player
	if player.gadget().gadget_info == null or player.gadget().uses_remaining == player.gadget().gadget_info.max_uses:
		return
	player.gadget().add_use()
