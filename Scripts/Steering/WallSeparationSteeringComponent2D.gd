class_name WallSeparationSteeringComponent2D
extends SteeringComponent2D

@export var buffer: float = 0
var body_radius: float = 0
@export var body_radius_override: float = -1
var wall_collision_mask: int

const CARD_DIRECTIONS := [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const DIAG_DIRECTIONS := [Vector2(0.7,0.7), Vector2(-0.7,0.7), Vector2(0.7,-0.7), Vector2(-0.7,-0.7)]
var direction_vectors := []

func _init() -> void:
	steering_type = STEERING_TYPE.WALL_SEPARATION

func _ready() -> void:
	super._ready()
	
	if(!parent.has_method("get_position")):
		print_debug("parent did not have required method get_position")
		running = false
	if(!parent.has_method("get_world_2d")):
		print_debug("parent did not have required method get_world_2d")
		running = false
	if(body_radius_override >= 0):
		body_radius = body_radius_override
	else:
		if(!parent.has_method("get_body_radius")):
			print_debug("parent did not have required method get_body_radius")
			running = false
		else:
			body_radius = parent.get_body_radius()
	
	wall_collision_mask = PhysicsUtil.get_physics_layer_mask([PhysicsUtil.get_physics_layer_bit("wall")])
	direction_vectors = []
	direction_vectors = CARD_DIRECTIONS + DIAG_DIRECTIONS

func calculate_steering_force():
	var current_position : Vector2 = parent.get_position()
	var world2D : World2D = parent.get_world_2d()
	
	steering_force = Vector2.ZERO
	var space_state := world2D.direct_space_state
	for i in direction_vectors.size():
		var dir: Vector2 = direction_vectors[i]
		var params := PhysicsRayQueryParameters2D.new()
		params.collision_mask = wall_collision_mask
		params.from = current_position
		params.to = current_position + dir * (buffer + body_radius)
		var result = space_state.intersect_ray(params)
		if(result is Dictionary && result.size() > 0):
			var collision_position : Vector2 = result["position"]
			var distance = (current_position - collision_position).length()
			var target_distance = body_radius + buffer
			var mag := 0.0
			if(distance <= 0):
				mag = 1.0
			elif(distance < target_distance):
				mag = (target_distance - distance)/(target_distance)
			steering_force -= dir * mag
	
	steering_force = steering_force.limit_length(1.0) * max_force

func draw():
	if(running && !is_equal_approx(steering_magnitude, 0)):
		for dir in direction_vectors:
			parent.draw_line(Vector2.ZERO, dir * (buffer + body_radius), Color.BLACK, 1.0)
		parent.draw_line(Vector2.ZERO, steering_force, Color.GREEN, 1.0)
