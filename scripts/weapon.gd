class_name Weapon

extends Node2D

@export var weapon_range: float = 2000
@export var damage: float = 5
@export var bullet_path_scene: PackedScene
@export var reload_time: float = 1
@export var max_ammo: int = 8
@export var firing_interval: float = 0.5

signal on_ammo_changed(ammo: int, max_ammo: int)

var ammo: int
var is_reloading: bool
var can_fire: bool

func _ready() -> void:
	ammo = max_ammo
	can_fire = true

func fire(pos: Vector2):
	if ammo <= 0 or !can_fire:
		return
	
	var mouse_position = get_global_mouse_position()

	var space_state = get_world_2d().direct_space_state
	var direction = (mouse_position - pos).normalized()
	var query = PhysicsRayQueryParameters2D.create(pos, pos + (direction * weapon_range))
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	var bullet_path = bullet_path_scene.instantiate() as Line2D
	get_tree().root.add_child(bullet_path)
	bullet_path.add_point(query.from, 0)
	bullet_path.add_point(query.to, 1)
	
	if result.get("collider") != null:
		var hit_collider = result.get("collider") as CollisionObject2D
		for child in hit_collider.get_children():
			if child is Health:
				var hit_object_health = child as Health
				hit_object_health.take_damage(damage)
		
	print("Hit: " + str(result))
	ammo -= 1
	on_ammo_changed.emit(ammo, max_ammo)
	if ammo <= 0:
		reload()
	shot_wait_time()
	
func shot_wait_time():
	can_fire = false
	await get_tree().create_timer(firing_interval).timeout
	
	if !is_reloading:
		can_fire = true
	
func reload():
	is_reloading = true
	can_fire = false
	await get_tree().create_timer(reload_time).timeout
	ammo = max_ammo
	on_ammo_changed.emit(ammo, max_ammo)
	can_fire = true
	is_reloading = false
