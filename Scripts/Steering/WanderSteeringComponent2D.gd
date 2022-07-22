class_name WanderSteeringComponent2D
extends SteeringComponent2D

@export var circle_radius: int = 20
@export var circle_distance: int = 50
@export var angle_change: float = 0.25

var wander_angle: float = 0.0
var circle_center: Vector2 = Vector2.ZERO
var displacement: Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	
	if(!parent.has_method("get_facing_direction")):
		print_debug("parent did not have required method get_facing_direction")
		running = false
	
	if(running):
		wander_angle = parent.get_facing_direction().angle()

func get_steer_type() -> int:
	return STEER_TYPE.ACTIVE

func calculate_steering_force():
	var facing_direction : Vector2 = parent.get_facing_direction()
	
	circle_center = Vector2.ZERO
	if(facing_direction != Vector2.ZERO):
		circle_center = facing_direction.normalized() * circle_distance
	
	displacement = Vector2(cos(wander_angle), sin(wander_angle)) * circle_radius
	wander_angle += (randf() - 0.5) * angle_change
	steering_force = (circle_center + displacement)
	
	steering_force = steering_force.normalized()

func draw():
	if(running):
		#parent.draw_circle(circle_center, circle_radius, Color.BLUE)
		parent.draw_arc(circle_center, circle_radius, 0, TAU, 10, Color.RED, false, 1.0)
		parent.draw_line(circle_center, circle_center + displacement, Color.RED, 1.0)
		parent.draw_line(Vector2.ZERO, steering_force*circle_distance, Color.RED, 1.0)
