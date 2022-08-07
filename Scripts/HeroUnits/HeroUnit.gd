extends Node2D

enum STATE {NULL, IDLE, AIMING}

var state = STATE.NULL

@export var debug_draw : bool = false

@onready var rotation_source_node: Node2D = get_node_or_null("%RotationNode")
@onready var visuals_source_node: Node2D = get_node_or_null("%VisualsNode")
@onready var target_detection_area: TargetDetectionCircle = get_node("%TargetDetectionCircle")

@export_range(0, 5000) var detection_range : int = 150 # the range at which the unit becomes "aware" of targets

@export_range(0, 5000) var body_rotation_speed_deg : float = 24 # body facing rotation speed : degrees per second
var body_rotation_speed : float # body facing rotation speed : radians per second
var target_node : Node2D

# aiming
@export_range(0, 5000) var max_aim_range : int = 100 # max aim range
@export_range(0, 1000) var aim_draw_speed : float = 20 # aim distance speed : pixels per second
@export_range(0, 180) var free_aim_angle_deg : float = 12 # max angle away from the facing direction for aiming, in degrees
var free_aim_angle : float # max angle away from the facing direction for aiming, in radians
var facing_rad : float = Vector2.RIGHT.angle() # unit body facing direction
var aim_point_center : Vector2 = Vector2.ZERO # aim point locked to unit facing direction
var free_aim_radius : float = 0 # radius around aim point for true aiming, limited by free_aim_angle
var free_aim_point_offset : Vector2 = Vector2.ZERO # true aim point offset constrained by free_aim_radius

func _ready() -> void:
	body_rotation_speed = deg2rad(body_rotation_speed_deg)
	free_aim_angle = deg2rad(free_aim_angle_deg)
	target_detection_area.set_detection_range(detection_range)
	target_detection_area.targets_changed.connect(_on_targets_change)
	
	state = STATE.IDLE

func _process(_delta: float) -> void:
	update()

func _physics_process(_delta: float) -> void:
	if(state == STATE.IDLE):
		if(target_node == null || !target_detection_area.is_valid_target(target_node)):
			#TODO : add some small delay to retargeting instead of running it every frame
			target_node = target_detection_area.get_closest_target_to_point(aim_point_center, max_aim_range)
		
		if(target_node != null):
			state = STATE.AIMING
	elif(state == STATE.AIMING):
		if(target_node == null || !target_detection_area.is_valid_target(target_node)):
			#TODO : add some small delay to retargeting instead of running it every frame
			target_node = target_detection_area.get_closest_target_to_point(aim_point_center, max_aim_range)
		
		if(target_node):
			#TODO : check if target is still (inside max_aim_range + free_aim_radius)
			#		if target is outside range for some small length of time, then try to retarget
			rotate_and_aim(target_node.get_global_position() - global_position, _delta)
		else:
			aim_point_center = Vector2.ZERO
		
		if(target_node == null):
			state = STATE.IDLE
	
	if(rotation_source_node):
		rotation_source_node.set_rotation(facing_rad)

func rotate_and_aim(local_aim_target: Vector2, _delta: float):
	# determine new body facing direction
	var target_rad := local_aim_target.angle()
	target_rad = unwrap_angle(target_rad)
	
	var new_rad := facing_rad
	new_rad = unwrap_angle(new_rad)

	if(target_rad - new_rad > PI):
		target_rad -= TAU
	if(new_rad - target_rad > PI):
		target_rad += TAU
	
	if(is_equal_approx(new_rad, target_rad)):
		new_rad = target_rad
	else:
		new_rad = tween_to(new_rad, target_rad, body_rotation_speed, _delta)
	
	# determine new aiming point, based on facing direction and final desired aim target
	var new_aim_point_center := aim_point_center
	if(aim_point_center.is_equal_approx(local_aim_target)):
		new_aim_point_center = local_aim_target
	elif(is_equal_approx(new_rad, target_rad)):
		# simple case, body has completed rotation just change aim distance
		var aim_distance = aim_point_center.length()
		var target_distance = local_aim_target.length()
		aim_distance = tween_to(aim_distance, target_distance, aim_draw_speed, _delta)
		new_aim_point_center = Vector2.from_angle(new_rad) * aim_distance
	else:
		# following a ~straight line towards final value based on body rotation
		# translating line to polar equation
		var v1 : Vector2 = aim_point_center
		var v2 : Vector2 = local_aim_target
		var s = (v2.y-v1.y) / (v2.x - v1.x)
		var c = v2.y - (s * v2.x)
		var r = c / (sin(new_rad) - s * cos(new_rad)) 
		
		var aim_distance = aim_point_center.length()
		var target_distance = r
		aim_distance = tween_to(aim_distance, target_distance, aim_draw_speed, _delta)
		new_aim_point_center = Vector2.from_angle(new_rad) * aim_distance
	new_aim_point_center = new_aim_point_center.limit_length(max_aim_range)
	
	# determine new free aim radius, based on aim point center and free_aim_angle
	var new_free_aim_radius := free_aim_radius
	if(free_aim_angle <= 0):
		new_free_aim_radius = 0
	if(!new_aim_point_center.is_equal_approx(aim_point_center)):
		var dist = new_aim_point_center.length()
		var test_point := Vector2.from_angle(new_rad + free_aim_angle) * dist
		new_free_aim_radius = (new_aim_point_center - test_point).length()
	
	# determine new free aim offset, based on free aim radius and final desired aim target
	var new_free_aim_point_offset : Vector2
	if(new_free_aim_radius > 0):
		new_free_aim_point_offset = (local_aim_target - new_aim_point_center).limit_length(new_free_aim_radius)
	else:
		new_free_aim_point_offset = new_aim_point_center
	
	facing_rad = new_rad
	aim_point_center = new_aim_point_center
	free_aim_radius = new_free_aim_radius
	free_aim_point_offset = new_free_aim_point_offset

# unwrap_angle(angle : float)
# utility method to convert an angle (in radians) to be in the range (0, TAU)
func unwrap_angle(angle : float):
	if(angle >= 0):
		var temp_angle = fmod(angle, TAU)
		return temp_angle
	else:
		var temp_angle = fmod(-angle, TAU)
		return TAU - temp_angle

# tween_to(initial: Variant, final: Variant, rate: float, delta: float, trans_type: TransitionType, ease_type: EaseType)
func tween_to(initial: Variant, final: Variant, rate: float, delta: float, trans_type := Tween.TRANS_QUINT, ease_type := Tween.EASE_OUT):
	var duration : float = 0
	if(initial is Vector2 || initial is Vector2i):
		duration = (final - initial).length() / rate
	else:
		duration = abs(final - initial) / rate
	if(duration < delta):
		return final
	else:
		return Tween.interpolate_value(initial, final - initial, delta, duration, trans_type, ease_type)

func _on_targets_change():
	pass

func _draw():
	if(!debug_draw):
		return
	
	# draw detection range circle
	draw_arc(Vector2.ZERO, detection_range, 0, TAU, 16, Color.RED)
	if(state == STATE.AIMING):
		# draw aim range circle
		draw_arc(Vector2.ZERO, max_aim_range, 0, TAU, 16, Color.RED)
		
		if(target_node != null):
			# draw current target enemy point
			draw_circle(target_node.get_global_position() - global_position, 4, Color.BLUE)
		
		if(!aim_point_center.is_equal_approx(Vector2.ZERO)):
			# draw current aim point
			draw_line(Vector2.ZERO, aim_point_center, Color.RED, 1.0)
			draw_circle(aim_point_center, 4, Color.RED)
			
			# draw current free aim point and area
			draw_circle(aim_point_center + free_aim_point_offset, 4, Color.GREEN)
			draw_arc(aim_point_center, free_aim_radius, 0, TAU, 16, Color.GREEN)
			if(!aim_point_center.is_equal_approx(Vector2.ZERO) && free_aim_radius > 0):
				var c_dist = aim_point_center.length()
				var c_angle = aim_point_center.angle()
				draw_line(Vector2.ZERO, Vector2.from_angle(c_angle + free_aim_angle) * c_dist, Color.GREEN, 1.0)
				draw_line(Vector2.ZERO, Vector2.from_angle(c_angle - free_aim_angle) * c_dist, Color.GREEN, 1.0)