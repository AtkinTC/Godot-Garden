class_name EnemyBody2D
extends AgentBody2D

@onready var rotation_source_node: Node2D = get_node_or_null("%RotationNode")
@onready var visuals_source_node: Node2D = get_node_or_null("%VisualsNode")

var target_position := Vector2.ZERO
var seek_vector := Vector2.ZERO

var nav_controller : NavigationController

var setup_params : Dictionary = {}

var hitstun_remaining : float = 0

@export var retarget_cooldown : float = 0
var retarget_time : float = 0

func set_setup_params(_params : Dictionary):
	setup_params = _params
	position = _params.get("position", position)
	nav_controller = _params.get("nav_controller", nav_controller)
	facing_rotation = _params.get("facing_rotation", facing_rotation)

func get_setup_params() -> Dictionary:
	return setup_params

func _ready() -> void:
	super._ready()
	attach_steering_components()

func _process(_delta: float) -> void:
	if(rotation_source_node):
		rotation_source_node.set_rotation(facing_rotation)
	update()

func _physics_process(delta: float) -> void:
	if(retarget_cooldown <= 0 || retarget_time <= 0):
		retarget_time = retarget_cooldown
		update_seek_target()
	if(retarget_time > 0):
		retarget_time -= delta
	
	calculate_steering_force(delta)
	
	super._physics_process(delta)
	
	if(!is_zero_approx(velocity_manual.length_squared())):
		facing_rotation = velocity_manual.angle()
		rotation_speed_manual = (velocity_manual.angle()-facing_rotation)
	
	if(hitstun_remaining >= 0):
		hitstun_remaining -= delta

func _draw() -> void:
	#draw_line(Vector2.ZERO, (practical_target_position - position).normalized() * max_speed, Color.blue, 2)
	#draw_line(Vector2.ZERO, move_vector, Color.green, 2)
	
#	var sc : SteeringComponent2D
#	sc = steering_components[SteeringComponent2D.STEERING_TYPE.WALL_SEPARATION]
#	if(sc != null):
#		sc.draw()
	
	#for steering_component in steering_components:
	#	steering_component.draw()
	pass

#############
# TARGETING #
#############

var min_target_distance := 20.0
func update_seek_target():
	if(position.distance_squared_to(target_position) < min_target_distance):
		#target already reached
		seek_vector = Vector2.ZERO
		return
	
	var flow_vector := nav_controller.get_goal_nav_direction(position, body_radius*2)
	seek_vector = flow_vector * max_speed
	return
	
#	var physics_layer_bit := PhysicsUtil.get_physics_layer_bit("wall")
#	var wall_collision_mask = PhysicsUtil.get_physics_layer_mask([physics_layer_bit])
#	var params := PhysicsRayQueryParameters2D.new()
#	params.collision_mask = wall_collision_mask
#	params.from = position
#	params.to = target_position
#	var result = get_world_2d().direct_space_state.intersect_ray(params)
#
#	if(result is Dictionary && result.size() > 0):
#		#wall in the direct line to the target, will use pathfinding instead
#		var flow_vector := nav_controller.get_nav_direction(position, target_position)
#		seek_target_position = position + flow_vector * max_speed
#		return
#	
#	seek_target_position = target_position

############
# STEERING #
############

var steering_components : Dictionary

func attach_steering_components():
	steering_components = {}
	for child in get_children():
		if(child is SteeringComponent2D):
			steering_components[child.get_steering_type()] = child

func calculate_steering_force(_delta: float) -> void:	
	# sum up different steering components
	var automatic_steering := Vector2.ZERO
	var manual_steering := Vector2.ZERO
	for steering_component in steering_components.values():
		if(steering_component.is_automatic()):
			automatic_steering += steering_component.steer()
		elif(hitstun_remaining <= 0):
			manual_steering += steering_component.steer()
	
	set_force(automatic_steering, TYPE.EXTERNAL)
	set_force(manual_steering, TYPE.MANUAL)

func apply_hitstun(duration: float) -> void:
	if(duration > hitstun_remaining):
		hitstun_remaining = duration

###################
# GETTERS/SETTERS #
###################

func set_target_position(_target_position : Vector2) -> void:
	target_position = _target_position

func get_target_position() -> Vector2:
	return target_position

func set_seek_vector(_seek_vector : Vector2):
	seek_vector = _seek_vector

func get_seek_vector() -> Vector2:
	return seek_vector

func _on_attack_collision(_attack_data: Dictionary):
	pass
