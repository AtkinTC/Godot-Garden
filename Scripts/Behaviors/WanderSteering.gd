class_name WanderSteering

const DEFAULT_RADIUS: int = 20
const DEFAULT_DISTANCE: int = 50
const DEFAULT_ANGLE_CHANGE: float = 0.25

var wander_angle: float
var circle_radius: int
var circle_distance: int
var angle_change: float

var circle_center: Vector2
var displacement: Vector2
var steering_vector: Vector2

func _init(_circle_radius: int = DEFAULT_RADIUS, _circle_distance: int = DEFAULT_DISTANCE, _angle_change: float = DEFAULT_ANGLE_CHANGE):
	wander_angle = 0.0
	circle_radius = _circle_radius
	circle_distance = _circle_distance
	angle_change = _angle_change
	
	circle_center = Vector2.ZERO
	displacement = Vector2.ZERO
	steering_vector = Vector2.ZERO

func steer(facing_direction: Vector2) -> Vector2:
	circle_center = Vector2.ZERO
	if(facing_direction != Vector2.ZERO):
		circle_center = facing_direction.normalized() * circle_distance
	
	displacement = Vector2(cos(wander_angle), sin(wander_angle)) * circle_radius
	wander_angle += (randf() - 0.5) * angle_change
	steering_vector = (circle_center + displacement)
	
	return steering_vector.normalized()

func draw(node: Node2D, color: Color = Color.GREEN):
	node.draw_arc(circle_center, circle_radius, 0, TAU, 10, Color.RED, false, 1.0)
	node.draw_line(circle_center, circle_center + displacement, Color.RED, 1.0)
	node.draw_line(Vector2.ZERO, steering_vector, color, 1.0)
