extends GunOverlay

@export var hiding_pos: Vector2

var _idle_shooter: IdleShooter
@onready var _standing_pos := position

func _ready() -> void:
	super()
	_idle_shooter = get_parent() as IdleShooter
	_idle_shooter.on_state_changed.connect(_adapt_state)
	
	_adapt_state(_idle_shooter._state)

func _adapt_state(state: IdleShooter.State) -> void:
	match state:
		IdleShooter.State.STANDING, IdleShooter.State.SHOOTING:
			_original_pos = _standing_pos
		IdleShooter.State.HIDING:
			_original_pos = hiding_pos
