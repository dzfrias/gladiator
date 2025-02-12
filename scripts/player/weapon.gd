class_name Weapon

extends Node2D

@export var weapon_stats: WeaponStats

signal on_ammo_changed(ammo: int, max_ammo: int)

@export var projectile_prefab: PackedScene
var ammo: int
var is_reloading: bool
var can_fire: bool
var is_firing: bool

func _ready() -> void:
	ammo = weapon_stats.max_ammo
	can_fire = true
	
func set_firing(on: bool):
	self.is_firing = on
	
func _process(_delta: float) -> void:
	if is_firing:
		fire()

func fire():
	if ammo <= 0 or !can_fire:
		return

	var space_state = get_world_2d().direct_space_state
	var direction = Vector2(Player.Instance.get_direction(), 0)
	
	var projectile = projectile_prefab.instantiate() as Projectile
	projectile._set_direction(direction)
	projectile._set_damage(weapon_stats.damage)
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	
	
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
