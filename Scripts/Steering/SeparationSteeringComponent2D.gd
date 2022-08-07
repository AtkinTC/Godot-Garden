# SeparationSteeringComponent2D
# Generates a force to keep a minimum separation distance between self and neighboring Collision Objects
# the desired separation is the sum of the two objects radii plus a buffer
# self.radius + target.radius + buffer
# a negative buffer can be used to allow overlap of the two objects with no separation force

class_name SeparationSteeringComponent2D
extends SteeringComponent2D

@export var buffer: float = 0
var body_radius: float = 0
@export var body_radius_override: float = -1

func _init() -> void:
	steering_type = STEERING_TYPE.SEPARATION

func _ready() -> void:
	super._ready()
	
	if(!parent.has_method("get_position")):
		print_debug("parent did not have required method get_position")
		running = false
	if(!parent.has_method("get_collision_layer")):
		print_debug("parent did not have required method get_collision_layer")
		running = false
	if(!parent.has_method("get_transform")):
		print_debug("parent did not have required method get_transform")
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

func calculate_steering_force():
	var current_position : Vector2 = parent.get_position()
	var collision_mask : int = parent.get_collision_layer()
	var transform2D : Transform2D = parent.get_transform()
	var space_state : PhysicsDirectSpaceState2D = parent.get_world_2d().get_direct_space_state()
	
	var shape = CircleShape2D.new()
	shape.radius = buffer + body_radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape_rid = shape.get_rid()
	query.collision_mask = collision_mask
	query.set_exclude([parent])
	query.transform = transform2D
	var results: Array = space_state.intersect_shape(query)
	
	steering_force = Vector2.ZERO
	for result in results:
		var collider: Node = (result as Dictionary).get("collider")
		if(collider is CollisionObject2D):
			var distance = current_position.distance_to(collider.position)
			var r2r_distance = distance - body_radius
			var target_distance = body_radius + buffer
			if(collider.has_method("get_body_radius")):
				target_distance += collider.get_body_radius()
				r2r_distance -= collider.get_body_radius()
				if(collider.get_body_radius() < body_radius):
					continue
			var mag := 0.0
			if(distance <= 0):
				mag = 1.0
			elif(distance < target_distance):
				#mag = (target_distance - distance)/(target_distance)
				mag = 1/max(r2r_distance,1)
			steering_force += (current_position - collider.position).normalized() * mag
	
	steering_force = steering_force.limit_length(1.0) * max_force

func draw():
	if(running && !is_equal_approx(steering_magnitude, 0)):
		parent.draw_line(Vector2.ZERO, steering_force * (buffer + body_radius), Color.GREEN, 1.0)
