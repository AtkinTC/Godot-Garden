class_name WallSeperationSteering

const DEFAULT_SEPERATION_DISTANCE: int = 30
const DEFAULT_MIN_SEPERATION_DISTANCE: int = 0

var seperation_distance: int
var min_seperation_distance: int
var wall_collision_mask: int

var nav_cont: Navigation

const BASE_DIRECTIONS := [Vector2(0.7,0.7), Vector2(-0.7,0.7), Vector2(0.7,-0.7), Vector2(-0.7,-0.7)]
var direction_vectors := []

var steering_vector: Vector2

func _init(_nav_cont : Navigation, _seperation_distance: int = DEFAULT_SEPERATION_DISTANCE, _min_seperation_distance: int = DEFAULT_MIN_SEPERATION_DISTANCE):
	nav_cont = _nav_cont
	seperation_distance = _seperation_distance
	min_seperation_distance = _min_seperation_distance
	steering_vector = Vector2.ZERO
	wall_collision_mask = PhysicsUtil.get_physics_layer_mask([PhysicsUtil.get_physics_layer_bit("wall")])
	direction_vectors = []
	for dir in BASE_DIRECTIONS:
		direction_vectors.append(dir)

func steer(node: Node2D) -> Vector2:
	steering_vector = Vector2.ZERO
	var space_state := node.get_world_2d().direct_space_state
	for i in direction_vectors.size():
		var dir: Vector2 = direction_vectors[i]
		var params := PhysicsRayQueryParameters2D.new()
		params.collision_mask = wall_collision_mask
		params.from = node.position
		params.to = node.position + dir * seperation_distance
		var result = space_state.intersect_ray(params)
		if(result is Dictionary && result.size() > 0):
			var dist = (node.position - (result["position"] as Vector2)).length()
			var mag := 0.0
			if(dist <= min_seperation_distance):
				mag = 1.0
			elif(dist < seperation_distance):
				mag = (seperation_distance as float - dist)/(seperation_distance - min_seperation_distance)
			steering_vector -= dir * mag
	
	return steering_vector.limit_length(1.0)

func draw(node: Node2D, color: Color = Color.GREEN):
	for dir in direction_vectors:
		node.draw_line(Vector2.ZERO, dir * seperation_distance, Color.BLACK, 1.0)
	node.draw_line(Vector2.ZERO, steering_vector * seperation_distance, color, 1.0)
