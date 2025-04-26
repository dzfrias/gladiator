extends StaticBody2D

func _ready() -> void:
	var player := Player.Instance as Player
	if player.gadget().gadget_info != null:
		$Sprite2D.texture = player.gadget().gadget_info.image

func _process(_delta: float) -> void:
	var collision := move_and_collide(Vector2.ZERO)
	if collision == null or collision.get_collider() is not Player:
		return
	
	queue_free()
	var player := collision.get_collider() as Player
	if player.gadget().gadget_info == null:
		return
	if player.gadget().uses_remaining == player.gadget().gadget_info.max_uses:
		return
	player.gadget().add_use()
