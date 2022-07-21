class_name SeekSteering

const DEFAULT_MAX_SPEED: float = 30.0

var max_speed: float

var steering_vector: Vector2

func _init(_max_speed: float = DEFAULT_MAX_SPEED):
	max_speed = _max_speed
	steering_vector = Vector2.ZERO

func steer(position: Vector2, target_position: Vector2, move_vector: Vector2) -> Vector2:
	var desired_vector := (target_position - position).normalized() * max_speed
	steering_vector = (desired_vector - move_vector).limit_length(max_speed) / max_speed
	return steering_vector

func draw(node: Node2D, color: Color = Color.GREEN):
	node.draw_line(Vector2.ZERO, steering_vector * max_speed, color, 1.0)
