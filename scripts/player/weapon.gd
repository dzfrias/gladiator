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
signal fired(projectile: Node2D)

var ammo: int
var effects: Node
var _weapon_stats: WeaponStats
var is_reloading: bool = false
var can_fire: bool = true
var _continuous_projectile: Node2D
var _prefire_flash: Node2D
var _ammo_time: float
var _muzzle_flash_scene: PackedScene = preload("res://scenes/muzzle_flash.tscn")
var _bullet_case_scene: PackedScene = preload("res://scenes/bullet_case.tscn")
var _prefire_flash_scene: PackedScene = preload("res://scenes/prefire_flash.tscn")

func _ready() -> void:
	if auto_activate_effects:
		activate_effects()

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
	if _continuous_projectile != null:
		var prev := int(_ammo_time)
		_ammo_time = maxf(_ammo_time - delta, 0.0)
		if int(_ammo_time) != prev:
			ammo -= 1
			on_ammo_changed.emit(ammo, weapon_stats.max_ammo)
		if _ammo_time == 0:
			_continuous_projectile.queue_free()
			_continuous_projectile = null

func continuous_fire(direction: Direction) -> void:
	assert(is_continuous())
	if _continuous_projectile != null or ammo == 0:
		return
	
	_continuous_projectile = weapon_stats.projectile.instantiate()
	_continuous_projectile.set_direction(direction)
	add_child(_continuous_projectile)

func stop_continuous_fire() -> void:
	assert(is_continuous())
	if _continuous_projectile == null:
		return
	_continuous_projectile.queue_free()
	_continuous_projectile = null

func fire(angle: float):
	assert(weapon_stats.firing_interval > 0)
	if ammo == 0 or !can_fire:
		return
	
	var projectile := weapon_stats.projectile.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	if projectile is PhysicsBody2D and get_parent() is PhysicsBody2D:
		projectile.add_collision_exception_with(get_parent())
	projectile.fire(angle)
	fired.emit(projectile)
	_do_effects(angle)
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
	if is_reloading:
		return
	is_reloading = true
	can_fire = false
	await get_tree().create_timer(weapon_stats.reload_time).timeout
	ammo = weapon_stats.max_ammo
	on_ammo_changed.emit(ammo, weapon_stats.max_ammo)
	can_fire = true
	is_reloading = false

func activate_prefire_flash() -> void:
	if _prefire_flash != null:
		_prefire_flash.queue_free()
	_prefire_flash = _prefire_flash_scene.instantiate() as Node2D
	add_child(_prefire_flash)

func deactivate_prefire_flash() -> void:
	assert(_prefire_flash != null)
	_prefire_flash.queue_free()
	_prefire_flash = null

func add_ammo(amt: int) -> void:
	ammo = mini(ammo + amt, weapon_stats.max_ammo)
	_ammo_time = minf(_ammo_time + amt, weapon_stats.max_ammo)
	on_ammo_changed.emit(ammo, weapon_stats.max_ammo)

func is_continuous() -> bool:
	return weapon_stats.firing_interval == 0

func _do_effects(angle: float) -> void:
	var muzzle_flash := _muzzle_flash_scene.instantiate() as TweenedScaler
	# We don't want the size of the muzzle flash to be linearly related to the strength of the
	# weapon. Instead, we're using a function with a decreasing rate of change (sqrt).
	muzzle_flash.end_scale = 3 * sqrt(weapon_stats.strength)
	var k := 1 if angle > -PI / 2 and angle < PI / 2 else -1
	muzzle_flash.position += Vector2(5 * k, -5)
	add_child(muzzle_flash)
	
	var bullet_case := _bullet_case_scene.instantiate() as BulletCase
	var bullet_case_angle := -2 * PI / 3 if angle > -PI / 2 and angle < PI / 2 else -PI / 3
	bullet_case.launch(bullet_case_angle)
	bullet_case.global_position = global_position
	# Similar to the muzzle flash scenario, bullet casing size shouldn't be linearly related to
	# strength.
	bullet_case.scale = Vector2.ONE * sqrt(weapon_stats.strength)
	get_tree().current_scene.add_child(bullet_case)
