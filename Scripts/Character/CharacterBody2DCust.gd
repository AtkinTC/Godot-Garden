class_name CharacterBody2DCust
extends CharacterBody2D

@export var roation_sourc_node: Node2D
@export var visuals_source_node: Node2D

var steering_force := Vector2.ZERO
@export var max_speed : float = 50.0
var move_vector := Vector2.ZERO

var target_position := Vector2.ZERO
var seek_target_position := Vector2.ZERO

var facing_direction := Vector2.RIGHT

var nav_controller : NavigationController

@onready var hurtbox: Hurtbox = get_node_or_null("Hurtbox")

var setup_params : Dictionary = {}

@export var retarget_cooldown : int = 0
var last_retarget : int = 0

#TODO: investigate way to base body radius off real collision shape
@export var body_radius : float = 0

func set_setup_params(_params : Dictionary):
	setup_params = _params
	position = _params.get("position", position)
	nav_controller = _params.get("nav_controller", nav_controller)
	facing_direction = _params.get("facing_direction", facing_direction)

func get_setup_params() -> Dictionary:
	return setup_params

func _ready() -> void:
	if(hurtbox is Hurtbox):
		hurtbox.connect_hit(_on_Hurtbox_took_hit)
	
	attach_steering_components()


func _process(delta: float) -> void:
	if(roation_sourc_node):
		roation_sourc_node.set_rotation(facing_direction.angle())
	update()

func _physics_process(delta: float) -> void:
	process_knockback(delta)
	
	if(retarget_cooldown == 0 || (Time.get_ticks_msec() - last_retarget) > retarget_cooldown):
		last_retarget = Time.get_ticks_msec()
		update_seek_target()
	
	calculate_steering_force(delta)
	
	move_vector += steering_force * delta
	move_vector.limit_length(max_speed)
	set_velocity(move_vector + get_knockback())
	move_and_slide()
	
	if(!move_vector.is_equal_approx(Vector2.ZERO) && !knockback_state):
		set_facing_direction(move_vector.normalized())
	
	#end knockback if collided
	if(get_slide_collision_count() > 0 && knockback_state):
		set_knockback(0.0)

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
		seek_target_position = position
		return
	
	#var flow_vector := nav_controller.get_targeted_nav_direction(position, target_position)
	var flow_vector := nav_controller.get_goal_nav_direction(position, body_radius*2)
	seek_target_position = position + flow_vector * max_speed
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
	
	seek_target_position = target_position

############
# STEERING #
############

var steering_components : Dictionary

func attach_steering_components():
	steering_components = {}
	for child in get_children():
		if(child is SteeringComponent2D):
			steering_components[child.get_steering_type()] = child

func calculate_steering_force(delta: float) -> void:	
	# sum up different steering components
	var automatic_steering := Vector2.ZERO
	var manual_steering := Vector2.ZERO
	var other_steering := Vector2.ZERO
	for steering_component in steering_components.values():
		if(steering_component.is_automatic()):
			automatic_steering += steering_component.steer()
		else:
			manual_steering += steering_component.steer()
	
	steering_force = Vector2.ZERO
	steering_force += automatic_steering
	if(!knockback_state):
		steering_force += manual_steering
	
	steering_force = (steering_force).limit_length(max_speed)

#############
# KNOCKBACK #
#############

var knockback_state := false
var knockback_impulse := 0.0
var knockback_direction := Vector2.ZERO

func set_knockback(_impulse: float, _direction: Vector2 = Vector2.ZERO):
	knockback_impulse = _impulse
	knockback_direction = _direction.normalized()
	if(knockback_impulse > 0.0):
		knockback_state = true
	else:
		knockback_impulse = 0.0
		knockback_state = false
	
func process_knockback(_delta: float):
	if(!knockback_state):
		return
	#knockback_impulse *= (1.0 - 0.95*_delta)
	knockback_impulse = lerp(knockback_impulse, 0.0, _delta)
	if(knockback_impulse <= 10.0):
		knockback_impulse = 0.0
		knockback_state = false

func get_knockback() -> Vector2:
	var knockback_vector = Vector2.ZERO
	if(!knockback_state):
		return knockback_vector
	
	knockback_vector = knockback_direction * knockback_impulse
	
	return knockback_vector

###################
# GETTERS/SETTERS #
###################

func set_facing_direction(_facing_direction) -> void:
	facing_direction = _facing_direction

func get_facing_direction() -> Vector2:
	return facing_direction

func set_target_position(_target_position : Vector2) -> void:
	target_position = _target_position

func get_target_position() -> Vector2:
	return target_position

func set_seek_target_position(_seek_target_position : Vector2):
	seek_target_position = _seek_target_position

func get_seek_target_position() -> Vector2:
	return seek_target_position

func get_max_speed() -> float:
	return max_speed

func get_body_radius() -> float:
	return body_radius

func _on_Hurtbox_took_hit(source: Hurtbox, hit_data: Dictionary):
	if(hit_data.has("damage")):
		pass
	
#	if(hit_data.has("knockback")):
#		var knockback_data: Dictionary = hit_data["knockback"]
#		var impulse = knockback_data.get("impulse")
#		var direction = knockback_data.get("direction")
#		set_knockback(impulse, direction)
	
