class_name PlayerMovementSettings extends Resource

@export var move_speed: float = 300:
	set(new):
		if move_speed != new:
			move_speed = new
			emit_changed()
@export var move_acceleration: float = 500
@export var move_deceleration: float = 800
@export var crouch_move_speed: float = 75
@export var shield_move_speed: float = 100
@export var direction_change_factor: float = 3
@export var njumps: int = 1
@export var jump_speed: float = 300
@export var jump_accel: float = 400
@export var jump_hold_time: float = 0.2
@export var jump_buffer_time: float = 0.2
@export var gravity_scale: float = 2.0
@export var fast_fall_gravity_scale: float = 2.0
@export var roll_speed: float = 600
@export var roll_time: float = 0.2
@export var roll_cooldown_time: float = 0.2
@export var invincible_time: float = 1.0
@export var burrow_speed: float = 500.0:
	set(new):
		if burrow_speed != new:
			burrow_speed = new
			emit_changed()
@export var burrow_speed_boost: float = 700.0
@export var max_burrow_time: float = 3.0
@export var burrow_increment_factor: float = 2.0
@export var burrow_decrement_factor: float = 0.5
