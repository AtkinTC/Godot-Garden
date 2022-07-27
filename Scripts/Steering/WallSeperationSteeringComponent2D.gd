class_name WallSeperationSteeringComponent2D
extends SteeringComponent2D

@export var outer_seperation_distance: float = 30
@export var inner_seperation_distance: float = 0
var wall_collision_mask: int

const BASE_DIRECTIONS := [Vector2(0.7,0.7), Vector2(-0.7,0.7), Vector2(0.7,-0.7), Vector2(-0.7,-0.7)]
var direction_vectors := []

func _init() -> void:
	steering_type = STEERING_TYPE.WALL_SEPERATION
	if(outer_seperation_distance < inner_seperation_distance):
		print_debug("outer_seperation_distance cannot be smaller than inner_seperation_distance")
		outer_seperation_distance = inner_seperation_distance

func _ready() -> void:
	super._ready()
	
	if(!parent.has_method("get_position")):
		print_debug("parent did not have required method get_position")
		running = false
	if(!parent.has_method("get_world_2d")):
		print_debug("parent did not have required method get_world_2d")
		running = false
	
	wall_collision_mask = PhysicsUtil.get_physics_layer_mask([PhysicsUtil.get_physics_layer_bit("wall")])
	direction_vectors = []
	for dir in BASE_DIRECTIONS:
		direction_vectors.append(dir)

func calculate_steering_force():
	var position : Vector2 = parent.get_position()
	var world2D : World2D = parent.get_world_2d()
	
	steering_force = Vector2.ZERO
	var space_state := world2D.direct_space_state
	for i in direction_vectors.size():
		var dir: Vector2 = direction_vectors[i]
		var params := PhysicsRayQueryParameters2D.new()
		params.collision_mask = wall_collision_mask
		params.from = position
		params.to = position + dir * outer_seperation_distance
		var result = space_state.intersect_ray(params)
		if(result is Dictionary && result.size() > 0):
			var dist = (position - (result["position"] as Vector2)).length()
			var mag := 0.0
			if(dist <= inner_seperation_distance):
				mag = 1.0
			elif(dist < outer_seperation_distance):
				mag = (outer_seperation_distance - dist)/(outer_seperation_distance - inner_seperation_distance)
			steering_force -= dir * max_force * mag
	
	steering_force = steering_force.limit_length(max_force)

func draw():
	if(running && !is_equal_approx(steering_magnitude, 0)):
		for dir in direction_vectors:
			parent.draw_line(Vector2.ZERO, dir * outer_seperation_distance, Color.BLACK, 1.0)
		parent.draw_line(Vector2.ZERO, steering_force * outer_seperation_distance, Color.GREEN, 1.0)
