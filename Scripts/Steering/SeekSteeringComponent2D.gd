class_name SeekSteeringComponent2D
extends SteeringComponent2D

func _ready() -> void:
	super._ready()
	
	if(!parent.has_method("get_position")):
		print_debug("parent did not have required method get_position")
		running = false
	if(!parent.has_method("get_seek_target_position")):
		print_debug("parent did not have required method get_seek_target_position")
		running = false
	if(!parent.has_method("get_max_speed")):
		print_debug("parent did not have required method get_max_speed")
		running = false
	if(!parent.has_method("get_velocity")):
		print_debug("parent did not have required method get_velocity")
		running = false

func get_steer_type() -> int:
	return STEER_TYPE.ACTIVE

func calculate_steering_force():
	var position : Vector2 = parent.get_position()
	var target_position : Vector2 = parent.get_seek_target_position()
	var max_speed : float = parent.get_max_speed()
	var velocity : Vector2 = parent.get_velocity()
	
	var desired_vector := (target_position - position).normalized() * max_speed
	steering_force = (desired_vector - velocity).limit_length(max_speed) / max_speed

func draw():
	if(running && !is_equal_approx(steering_magnitude, 0)):
		parent.draw_line(Vector2.ZERO, steering_force * parent.get_max_speed(), Color.GREEN, 1.0)
