extends AnimatedSprite2D

@export var walk_cuttoff_point: float

var _suispider: Suispider

func _ready() -> void:
	_suispider = get_parent() as Suispider
	_suispider.jumped.connect(_on_jump)
	_suispider.called_lightning_pre.connect(_on_called_lightning_pre)

func _process(_delta: float) -> void:
	if animation != "lightning" and _suispider.is_on_floor():
		if abs(_suispider.velocity.x) > walk_cuttoff_point:
			play("run")
		elif abs(_suispider.velocity.x) > 0:
			play("walk")
		elif abs(_suispider.velocity.x) == 0:
			play("idle")
	
	flip_h = not _suispider.direction().is_right

func _on_jump() -> void:
	play("jump")

func _on_called_lightning_pre() -> void:
	play("lightning")
	await _suispider.called_lightning
	play("walk")
