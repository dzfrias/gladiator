extends Area2D

func _ready() -> void:
	body_entered.connect(on_area_entered)

func on_area_entered(body):
	if Player.Instance.alt_weapon().weapon_stats == null:
		return
	
	Player.Instance.alt_weapon().add_ammo(Player.Instance.alt_weapon().weapon_stats.ammo_collect_amount)
	queue_free()
