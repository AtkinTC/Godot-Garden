class_name SeperationSteering

const DEFAULT_SEPERATION_DISTANCE: int = 30
const DEFAULT_MIN_SEPERATION_DISTANCE: int = 0

var seperation_distance: int
var min_seperation_distance: int

var steering_vector: Vector2

func _init(_seperation_distance: int = DEFAULT_SEPERATION_DISTANCE, _min_seperation_distance: int = DEFAULT_MIN_SEPERATION_DISTANCE):
	seperation_distance = _seperation_distance
	min_seperation_distance = _min_seperation_distance
	steering_vector = Vector2.ZERO

func steer(node: Node2D) -> Vector2:
	steering_vector = Vector2.ZERO
	
	var shape = CircleShape2D.new()
	shape.radius = seperation_distance

	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape_rid = shape.get_rid()
	query.collision_mask = node.collision_layer
	query.set_exclude([node])
	query.transform = node.global_transform
	var results: Array = node.get_world_2d().direct_space_state.intersect_shape(query)
	
	if(results.size() == 0):
		return Vector2.ZERO
	
	for result in results:
		var collider: Node = (result as Dictionary).get("collider")
		if(collider is CollisionObject2D):
			var distance = node.position.distance_to(collider.position)
			var mag := 0.0
			if(distance <= min_seperation_distance):
				mag = 1.0
			if(distance < seperation_distance):
				mag = (seperation_distance - distance)/(seperation_distance - min_seperation_distance)
			steering_vector += (node.position - collider.position).normalized() * mag
	
	return steering_vector.limit_length(1.0)

func draw(node: Node2D, color: Color = Color.GREEN):
	node.draw_line(Vector2.ZERO, steering_vector * seperation_distance, color, 1.0)
