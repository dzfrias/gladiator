class_name Weapon

extends Node2D

@export var weapon_stats: WeaponStats

signal on_ammo_changed(ammo: int, max_ammo: int)

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
	
	var mouse_position = get_global_mouse_position()

	var space_state = get_world_2d().direct_space_state
	var direction = (mouse_position - global_position).normalized()
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + (direction * weapon_stats.weapon_range))
	query.collide_with_areas = true
	query.collision_mask = Constants.ENTITY_LAYER | Constants.ENVIRONMENT_LAYER
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	Debug.draw_line(query.from, query.to, 10.0, Color.RED, 0.05)
	
	if result.get("collider") != null:
		var hit_collider = result.get("collider")
		
		for child in hit_collider.get_children():
			if child is Health:
				var hit_object_health = child as Health
				hit_object_health.take_damage(weapon_stats.damage, direction)
		
	print("Hit: " + str(result))
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
