class_name Weapon extends Node2D

@export var weapon_stats: WeaponStats:
	get: return _weapon_stats
	set(stats):
		if stats != null:
			ammo = stats.max_ammo
			_ammo_time = stats.max_ammo
		_weapon_stats = stats
@export var auto_reload = false
@export var auto_activate_effects = true

signal on_ammo_changed(ammo: int, max_ammo: int)

var ammo: int
var effects: Node
var _weapon_stats: WeaponStats
var is_reloading: bool = false
var can_fire: bool = true
# NOTE when this field is null, we are not firing
var _fire_direction: Direction = null
var _continuous_projectile: Node2D
var _ammo_time: float

func _ready() -> void:
	if auto_activate_effects:
		activate_effects()

func set_firing(direction: Direction):
	_fire_direction = direction

func is_firing() -> bool:
	return _fire_direction != null

func activate_effects() -> void:
	assert(effects == null)
	if weapon_stats.effects == null:
		return
	effects = weapon_stats.effects.instantiate()
	add_child(effects)

func deactivate_effects() -> void:
	if weapon_stats.effects == null:
		return
	assert(effects != null)
	effects.queue_free()
	effects = null

func _process(delta: float) -> void:
	if not is_firing():
		if _continuous_projectile != null:
			_continuous_projectile.queue_free()
			_continuous_projectile = null
		return
	
	if weapon_stats.firing_interval > 0:
		fire(_fire_direction)
	elif _continuous_projectile == null and ammo > 0:
		_continuous_projectile = weapon_stats.projectile.instantiate()
		_continuous_projectile.set_direction(_fire_direction)
		add_child(_continuous_projectile)
	
	if _continuous_projectile != null:
		var prev = int(_ammo_time)
		_ammo_time -= delta
		if int(_ammo_time) != prev:
			ammo -= 1
			on_ammo_changed.emit(ammo, weapon_stats.max_ammo)
		if _ammo_time <= 0:
			_continuous_projectile.queue_free()
			_continuous_projectile = null

func fire(direction: Direction):
	if ammo == 0 or !can_fire:
		return
	
	var projectile := weapon_stats.projectile.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	var angle: float
	match weapon_stats.aim_mode:
		WeaponStats.AimMode.BIDIRECTIONAL:
			angle = 0.0 if direction.is_right else PI
		WeaponStats.AimMode.OMNIDIRECTIONAL:
			angle = get_angle_to(get_global_mouse_position())
	
	projectile.fire(angle)
	projectile.global_position = global_position
	
	if ammo > 0:
		ammo -= 1
	on_ammo_changed.emit(ammo, weapon_stats.max_ammo)
	if ammo == 0 and auto_reload:
		reload()
		return
	
	can_fire = false
	await get_tree().create_timer(weapon_stats.firing_interval).timeout
	if !is_reloading:
		can_fire = true

func reload():
	is_reloading = true
	can_fire = false
	await get_tree().create_timer(weapon_stats.reload_time).timeout
	ammo = weapon_stats.max_ammo
	on_ammo_changed.emit(ammo, weapon_stats.max_ammo)
	can_fire = true
	is_reloading = false
