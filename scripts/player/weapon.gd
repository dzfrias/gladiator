class_name Weapon extends Node2D

@export var weapon_stats: WeaponStats
@export var projectile_prefab: PackedScene

signal on_ammo_changed(ammo: int, max_ammo: int)

var ammo: int
var is_reloading: bool = false
var can_fire: bool = true
# NOTE when this field is null, we are not firing
var _fire_direction: Direction = null

func _ready() -> void:
	ammo = weapon_stats.max_ammo
	
func set_firing(direction: Direction):
	_fire_direction = direction
	
func _process(_delta: float) -> void:
	if _fire_direction != null:
		fire(_fire_direction)

func fire(direction: Direction):
	if ammo <= 0 or !can_fire:
		return
	
	var projectile = projectile_prefab.instantiate()
	var angle: float
	if direction.is_right:
		angle = 0.0
	else:
		angle = PI
	angle = randfn(angle, weapon_stats.angle_variance)
	projectile.fire(weapon_stats.projectile_speed, angle)
	projectile.damage = weapon_stats.damage
	projectile.global_position = global_position
	get_tree().root.add_child(projectile)
	
	ammo -= 1
	on_ammo_changed.emit(ammo, weapon_stats.max_ammo)
	if ammo <= 0:
		reload()
	shot_wait_time()
	
func shot_wait_time():
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
