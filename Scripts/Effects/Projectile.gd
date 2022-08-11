# Projectile extend Effect
# 	simple projectile effect node

class_name Projectile
extends Effect

const MAX_RANGE = 2000
const MIN_RAY_LENGTH = 1

var source : Node2D
var position_init : Vector2
var collision_mask : int = 0
var speed : float = 100
var max_range : float = 0
var max_range_sqr : float = 0
var damage : float = 0

func setup_from_attribute_dictionary(_attribute_dict: Dictionary):
	super.setup_from_attribute_dictionary(_attribute_dict)
	
	source = _attribute_dict.get("source", null)
	collision_mask = _attribute_dict.get("collision_mask", collision_mask)
	speed = _attribute_dict.get("speed", speed)
	damage = _attribute_dict.get("damage", damage)
	
	max_range = _attribute_dict.get("max_range", MAX_RANGE)
	if(max_range <= 0 || max_range > MAX_RANGE):
		max_range = MAX_RANGE
	max_range_sqr = max_range * max_range
	
	position_init = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if(position.distance_squared_to(position_init) > max_range_sqr):
		queue_free()
		return
	
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().get_direct_space_state()
	
	var ray_query = PhysicsRayQueryParameters2D.new()
	ray_query.from = global_position
	ray_query.to = global_position + Vector2.from_angle(global_rotation) * max(speed * _delta, MIN_RAY_LENGTH)
	ray_query.collision_mask = collision_mask
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = true
	ray_query.hit_from_inside = true
	
	var collision : Dictionary = space_state.intersect_ray(ray_query)
	
	var collider : Node = collision.get("collider", null)
	if(collider != null):
		if(collider.has_method("_on_attack_collision")):
			var attack_data = {
				AttackConsts.POSITION : collision.position,
				AttackConsts.NORMAL : collision.normal,
				AttackConsts.ANGLE : global_rotation,
				AttackConsts.FORCE : 50
			}
			collider._on_attack_collision(attack_data)
		queue_free()
		return
	
	position += Vector2.from_angle(global_rotation) * speed * _delta
	
	update()

#func _draw() -> void:
#	draw_line(Vector2.ZERO, Vector2.RIGHT * speed, Color.RED, 2.0)
