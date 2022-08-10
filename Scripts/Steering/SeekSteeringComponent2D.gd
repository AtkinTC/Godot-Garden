class_name SeekSteeringComponent2D
extends SteeringComponent2D

func _init() -> void:
	steering_type = STEERING_TYPE.SEEK

func _ready() -> void:
	super._ready()
	
	if(!parent.has_method("get_position")):
		print_debug("parent did not have required method get_position")
		running = false
	if(!parent.has_method("get_seek_vector")):
		print_debug("parent did not have required method get_seek_vector")
		running = false
	if(!parent.has_method("get_max_speed")):
		print_debug("parent did not have required method get_max_speed")
		running = false
	if(!parent.has_method("get_velocity")):
		print_debug("parent did not have required method get_velocity")
		running = false

func calculate_steering_force():
	var seek_vector : Vector2 = parent.get_seek_vector()
	var max_speed : float = parent.get_max_speed()
	var velocity : Vector2 = parent.get_velocity()
	
	var desired_velocity := seek_vector.limit_length(max_speed)
	steering_force = (desired_velocity - velocity).limit_length(max_force)

func draw():
	if(running && !is_equal_approx(steering_magnitude, 0)):
		parent.draw_line(Vector2.ZERO, steering_force * parent.get_max_speed(), Color.GREEN, 1.0)
