# HeroUnit extends Node2D
# 	semi-autonomous hero units
#	engages in combat with enemy units and takes orders from the player

class_name HeroUnit
extends Node2D

enum STATE {NULL, IDLE, AIMING, SHOOTING, RELOADING, MOVING}

var state = STATE.NULL

var next_state = STATE.NULL
var queued_state = STATE.NULL

@export var debug_draw : bool = false

@onready var fixed_rotation_node: Node2D = get_node_or_null("%FixedRotationNode")
@onready var visuals_source_node: Node2D = get_node_or_null("%VisualsNode")
@onready var target_detection_area: TargetDetectionCircle = get_node("%TargetDetectionCircle")

@onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")

@onready var gun : GunBase = get_node_or_null("%Gun")

var heroes_node : HeroesNode

# targeting
@export_range(0, 5000) var detection_range : int = 200 # the range at which the unit becomes "aware" of targets
@export_range(0, 5000) var body_rotation_speed_deg : float = 90 # body facing rotation speed : degrees per second
@onready var body_rotation_speed : float = deg2rad(body_rotation_speed_deg) # body facing rotation speed : radians per second
var target_node : Node2D
@export var target_layer_names : Array[String] = []
var target_mask : int = 0

var retarget_wait_duration : float = 1
var retarget_wait_time_remaining : float = 0

# aiming
@export_range(0, 5000) var max_aim_range : int = 150 # max aim range
@export_range(0, 1000) var aim_draw_speed : float = 20 # aim distance speed : pixels per second
@export_range(0, 180) var free_aim_angle_deg : float = 12 # max angle away from the facing direction for aiming, in degrees
@onready var free_aim_angle : float = deg2rad(free_aim_angle_deg) # max angle away from the facing direction for aiming, in radians
var aim_point_center : Vector2 = Vector2.ZERO # aim point locked to unit facing direction
var free_aim_radius : float = 0 # radius around aim point for true aiming, limited by free_aim_angle
var free_aim_point_offset : Vector2 = Vector2.ZERO # true aim point offset constrained by free_aim_radius

#navigation
var nav_controller : NavigationController
var move_distance : int = 8
var move_speed : float = 60
var move_target : Vector2
var move_path : Array[Vector2] = []

func _ready() -> void:
	var parent = get_parent()
	if(parent is HeroesNode):
		heroes_node = parent
	
	target_mask = PhysicsUtil.get_physics_layer_mask_from_names(target_layer_names)
	
	target_detection_area.set_detection_range(detection_range)
	target_detection_area.targets_changed.connect(_on_targets_change)
	target_detection_area.set_collision_mask(target_mask)
	
	animation_player.animation_finished.connect(_on_animation_finished)
	
	state = STATE.IDLE
	
	call_deferred("post_ready")

# deferred ready function for additional setup that relies on other nodes being ready
func post_ready() -> void:
	if(nav_controller == null):
		var world : World = ResourceRef.get_current_game_world()
		if(world != null):
			nav_controller = world.get_navigation_controller()

func _process(_delta: float) -> void:
	if(fixed_rotation_node):
		fixed_rotation_node.set_global_rotation(0)
	update()

func _physics_process(_delta: float) -> void:
	if(queued_state != STATE.NULL):
		#TODO: check if state change is valid
		next_state = queued_state
		queued_state = STATE.NULL
	
	if(next_state != STATE.NULL):
		state = next_state
	
	var animation_name : String = "idle"
	
	# IDLE
	if(state == STATE.IDLE):
		animation_name = "aim"
		
		reset_aim()
		retarget_if_needed(_delta)
		
		if(target_node != null):
			next_state = STATE.AIMING
	
	# MOVING
	if(state == STATE.MOVING):
		animation_name = "walk"
		
		reset_aim()
		
		if(move_path == null || move_path.size() <= 0):
			move_path = get_nav_path(move_target)
		
		if(move_path != null && move_path.size() > 0):
			if((move_path[0] - position).length() <= (move_speed * _delta)):
				position = move_path[0]
				move_path.pop_front()
			else:
				rotation = (move_path[0] - position).angle()
				position += (move_path[0] - position).normalized() * move_speed * _delta
		
		if(move_path.size() <= 0):
			move_path = []
			next_state = STATE.IDLE
	
	# AIMING
	if(state == STATE.AIMING):
		animation_name = "aim"
		
		retarget_if_needed(_delta)
		
		if(target_node):
			rotate_and_aim(predict_aim_target(), _delta)
		else:
			aim_point_center = Vector2.ZERO
		
		if(target_node && predict_aim_target().is_equal_approx(aim_point_center + free_aim_point_offset)):
			shoot_gun()
			animation_name = "shoot"
			next_state = STATE.SHOOTING
		elif(target_node == null):
			next_state = STATE.IDLE
	
	#SHOOTING
	if(state == STATE.SHOOTING):
		animation_name = "shoot"
	
	#RELOADING
	if(state == STATE.RELOADING):
		animation_name = "reload"
		
		reset_aim()
	
	if(animation_player.has_animation(animation_name) && animation_player.get_current_animation() != animation_name):
		animation_player.play(animation_name)

# updates the target_node if both:
#		a) current target_node null or not within max_aim_range
#		b) time passed since last retarget has reached retarget_wait_duration
func retarget_if_needed(_delta: float):
	retarget_wait_time_remaining -= _delta
	if(target_node == null || !target_node is Node):
		target_node = null
	if(target_node != null && !target_detection_area.is_valid_target(target_node)):
		target_node = null
	if(target_node != null):
		if((target_node.get_global_position() - global_position).length_squared() <= (max_aim_range * max_aim_range)):
			retarget_wait_time_remaining = retarget_wait_duration
	if(target_node == null || retarget_wait_time_remaining <= 0):
		target_node = target_detection_area.get_closest_target_to_point(aim_point_center, max_aim_range)
		retarget_wait_time_remaining = retarget_wait_duration

# returns the local predicted aim target
#	makes prediction based off of target distance, target velocity, and projectile speed
func predict_aim_target() -> Vector2:
	if(target_node == null):
		return Vector2.ZERO
	
	var local_aim_target = target_node.get_global_position() - global_position
	if(not gun is GunBase || is_zero_approx(gun.get_projectile_speed())):
		return local_aim_target
	
	if(!target_node.has_method("get_velocity")):
		return local_aim_target
	var v : Vector2 = target_node.get_velocity()
	var d : float = local_aim_target.length()
	var t : float = d/gun.get_projectile_speed()
	var predicted_aim_target = local_aim_target + v * t
	return(predicted_aim_target)

func reset_aim():
	aim_point_center = Vector2.ZERO
	free_aim_radius = 0
	free_aim_point_offset = Vector2.ZERO

func rotate_and_aim(local_aim_target: Vector2, _delta: float):
	# determine new body facing direction
	var target_rad := local_aim_target.angle()
	target_rad = Utils.unwrap_angle(target_rad)
	
	var new_rad := Utils.unwrap_angle(rotation)

	if(target_rad - new_rad > PI):
		target_rad -= TAU
	if(new_rad - target_rad > PI):
		target_rad += TAU
	
	if(is_equal_approx(new_rad, target_rad)):
		new_rad = target_rad
	else:
		new_rad = Utils.tween_to(new_rad, target_rad, body_rotation_speed, _delta)
	
	# determine new aiming point, based on facing direction and final desired aim target
	var new_aim_point_center := aim_point_center
	if(aim_point_center.is_equal_approx(local_aim_target)):
		new_aim_point_center = local_aim_target
	elif(is_equal_approx(new_rad, target_rad)):
		# simple case, body has completed rotation just change aim distance
		var aim_distance = aim_point_center.length()
		var target_distance = local_aim_target.length()
		aim_distance = Utils.tween_to(aim_distance, target_distance, aim_draw_speed, _delta)
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
		aim_distance = Utils.tween_to(aim_distance, target_distance, aim_draw_speed, _delta)
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
	
	rotation = new_rad
	aim_point_center = new_aim_point_center
	free_aim_radius = new_free_aim_radius
	free_aim_point_offset = new_free_aim_point_offset

func shoot_gun():
	if(gun is GunBase):
		gun.shoot(self)

func initiate_move(_move_target: Vector2):
	queued_state = STATE.MOVING
	move_target = _move_target

func get_map_cell() -> Vector2i:
	return nav_controller.world_to_map(global_position)

func get_navigation_controller() -> NavigationController:
	return nav_controller

func get_reserved_cells() -> Array[Vector2i]:
	if(state == STATE.MOVING):
		return [nav_controller.world_to_map(move_target)]
	else:
		return [get_map_cell()]

func get_possible_move_targets() -> Array[Vector2i]:
	if(nav_controller == null):
		return []
	
	var move_targets = nav_controller.get_nav_cells_in_range(self.position, move_distance)
	
	if(heroes_node):
		var reserved_cells : Array[Vector2i] = heroes_node.get_reserved_cells()
		for cell in reserved_cells:
			move_targets.erase(cell)
	
	return move_targets

func get_nav_path(target_pos : Vector2) -> Array[Vector2]:
	return nav_controller.get_nav_path(global_position, target_pos, 8)

func _on_targets_change():
	pass

func _on_animation_finished(_anim_name: StringName):
	if(state == STATE.SHOOTING):
		if(gun is GunBase && gun.needs_reload()):
			next_state = STATE.RELOADING
		else:
			next_state = STATE.AIMING
	if(state == STATE.RELOADING):
		gun.complete_reload()
		next_state = STATE.AIMING

func _draw():
	if(!debug_draw):
		return
	
	# draw detection range circle
	draw_arc(Vector2.ZERO, detection_range, 0, TAU, 32, Color.RED)
	
	if(state == STATE.AIMING || state == STATE.SHOOTING):
		# draw aim range circle
		draw_arc(Vector2.ZERO, max_aim_range, 0, TAU, 32, Color.RED)
		
		if(target_node != null):
			# draw current target enemy point
			var adj_target_pos := (target_node.get_global_position() - global_position).rotated(-rotation)
			draw_circle(adj_target_pos, 2, Color.BLUE)
		
		if(!aim_point_center.is_equal_approx(Vector2.ZERO)):
			var adj_aim_point_center := aim_point_center.rotated(-rotation)
			
			# draw current aim point
			draw_line(Vector2.ZERO, adj_aim_point_center, Color.RED, 1.0)
			draw_circle(adj_aim_point_center, 2, Color.RED)
			
			# draw current free aim point and area
			draw_circle(adj_aim_point_center + free_aim_point_offset.rotated(-rotation), 2, Color.GREEN)
			draw_arc(adj_aim_point_center, free_aim_radius, 0, TAU, 16, Color.GREEN)
			if(!aim_point_center.is_equal_approx(Vector2.ZERO) && free_aim_radius > 0):
				var c_dist = adj_aim_point_center.length()
				var c_angle = adj_aim_point_center.angle()
				draw_line(Vector2.ZERO, Vector2.from_angle(c_angle + free_aim_angle) * c_dist, Color.GREEN, 1.0)
				draw_line(Vector2.ZERO, Vector2.from_angle(c_angle - free_aim_angle) * c_dist, Color.GREEN, 1.0)
