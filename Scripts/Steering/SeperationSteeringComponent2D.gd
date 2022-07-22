class_name SeperationSteeringComponent2D
extends SteeringComponent2D

@export var seperation_distance: int = 30
@export var min_seperation_distance: int = 0

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

func get_steer_type() -> int:
	return STEER_TYPE.PASSIVE

func calculate_steering_force():
	var position : Vector2 = parent.get_position()
	var collision_mask : int = parent.get_collision_layer()
	var transform2D : Transform2D = parent.get_transform()
	var world2D : World2D = parent.get_world_2d()
	
	var shape = CircleShape2D.new()
	shape.radius = seperation_distance
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape_rid = shape.get_rid()
	query.collision_mask = collision_mask
	query.set_exclude([parent])
	query.transform = transform2D
	var results: Array = world2D.direct_space_state.intersect_shape(query)
	
	steering_force = Vector2.ZERO
	for result in results:
		var collider: Node = (result as Dictionary).get("collider")
		if(collider is CollisionObject2D):
			var distance = position.distance_to(collider.position)
			var mag := 0.0
			if(distance <= min_seperation_distance):
				mag = 1.0
			if(distance < seperation_distance):
				mag = (seperation_distance - distance)/(seperation_distance - min_seperation_distance)
			steering_force += (position - collider.position).normalized() * mag
	
	steering_force = steering_force.limit_length(1.0)

func draw():
	if(running && !is_equal_approx(steering_magnitude, 0)):
		parent.draw_line(Vector2.ZERO, steering_force * seperation_distance, Color.GREEN, 1.0)
