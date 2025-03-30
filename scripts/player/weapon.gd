class_name Weapon extends Node2D

@export var weapon_stats: WeaponStats:
	get: return _weapon_stats
	set(stats):
		if stats != null:
			ammo = stats.max_ammo
		_weapon_stats = stats
@export var auto_reload = false

signal on_ammo_changed(ammo: int, max_ammo: int)

var ammo: int
var _weapon_stats: WeaponStats
var is_reloading: bool = false
var can_fire: bool = true
# NOTE when this field is null, we are not firing
var _fire_direction: Direction = null

func set_firing(direction: Direction):
	_fire_direction = direction

func is_firing() -> bool:
	return _fire_direction != null

func _process(_delta: float) -> void:
	if is_firing():
		fire(_fire_direction)

func fire(direction: Direction):
	if ammo == 0 or !can_fire:
		return
	
	var projectile := weapon_stats.projectile.instantiate()
	get_tree().current_scene.add_child(projectile)
	var angle := 0.0 if direction.is_right else PI
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
