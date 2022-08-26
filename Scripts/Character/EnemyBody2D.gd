class_name EnemyBody2D
extends AgentBody2D

@onready var fixed_rotation_node: Node2D = get_node_or_null("%FixedRotationNode")
@onready var visuals_node: Node2D = get_node_or_null("%VisualsNode")

const DEATH_ANIM_KEY = "fall"
const DEATH_F_ANIM_KEY = DEATH_ANIM_KEY + "_forward"
const DEATH_B_ANIM_KEY = DEATH_ANIM_KEY + "_backward"
const DEATH_R_ANIM_KEY = DEATH_ANIM_KEY + "_right"
const DEATH_L_ANIM_KEY = DEATH_ANIM_KEY + "_left"

const STAGGER_ANIM_KEY = "stagger"
const STAGGER_F_ANIM_KEY = STAGGER_ANIM_KEY + "_forward"
const STAGGER_B_ANIM_KEY = STAGGER_ANIM_KEY + "_backward"
const STAGGER_R_ANIM_KEY = STAGGER_ANIM_KEY + "_right"
const STAGGER_L_ANIM_KEY = STAGGER_ANIM_KEY + "_left"

enum STATE {NULL, DEFAULT, STAGGER, DEAD}

var state = STATE.NULL

@export var health_max : int = 2
@onready var health : float = health_max

@export var pre_death_effects : Array[PackedScene]
@export var post_death_effects : Array[PackedScene]

var seek_target_position : Vector2

@onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")

var target_position := Vector2.ZERO
var seek_vector := Vector2.ZERO

var nav_controller : NavigationController

var setup_params : Dictionary = {}

var hitstun_remaining : float = 0

@export var retarget_cooldown : float = 0
var retarget_time : float = 0

var last_animation_change_time : int = 0

func set_setup_params(_params : Dictionary):
	setup_params = _params
	position = _params.get("position", position)
	nav_controller = _params.get("nav_controller", nav_controller)
	rotation = _params.get("rotation", rotation)

func get_setup_params() -> Dictionary:
	return setup_params

func _ready() -> void:
	super._ready()
	attach_steering_components()
	animation_player.animation_finished.connect(_on_animation_finished)
	state = STATE.DEFAULT

func _process(_delta: float) -> void:
	if(state != STATE.DEAD && state != STATE.STAGGER):
		var v = velocity
		var s = v.length()
		
		if(last_animation_change_time == 0 || Time.get_ticks_msec() - last_animation_change_time > 500):
			var desired_animation : String = "idle"
			
			if(s < 1):
				desired_animation = "idle"
			elif(s < 15):
				desired_animation = "walking"
			else:
				desired_animation = "running"
			
			if(animation_player.has_animation(desired_animation) && animation_player.get_current_animation() != desired_animation):
				animation_player.play(desired_animation)
				last_animation_change_time = Time.get_ticks_msec()
				
	if(fixed_rotation_node):
		fixed_rotation_node.set_global_rotation(0)
	update()

func _physics_process(delta: float) -> void:
	if(health <= 0 && state != STATE.DEAD):
		if(state != STATE.DEAD):
			begin_state_death()
	
	if(state != STATE.DEAD && state != STATE.STAGGER && hitstun_remaining > 0):
		begin_state_stagger()
	
	if(state == STATE.DEAD):
		set_force(Vector2.ZERO, TYPE.MANUAL)
	
	if(state == STATE.STAGGER):
		set_force(Vector2.ZERO, TYPE.MANUAL)
		
		if(hitstun_remaining >= 0):
			hitstun_remaining -= delta
		else:
			state = STATE.DEFAULT
	
	if(state != STATE.DEAD):
		if(retarget_cooldown <= 0 || retarget_time <= 0):
			retarget_time = retarget_cooldown
			update_seek_target()
		if(retarget_time > 0):
			retarget_time -= delta
		
		calculate_steering_force(delta)
		
	super._physics_process(delta)
	
	if(state != STATE.DEAD):
		if(!is_zero_approx(velocity_manual.length_squared())):
			rotation = velocity_manual.angle()
			rotation_speed_manual = (velocity_manual.angle() - rotation)
	

func begin_state_stagger():
	state = STATE.STAGGER
	var external_force_angle : float = (get_force(TYPE.EXTERNAL) + get_impulse(TYPE.EXTERNAL)).angle()
	var stagger_angle = Utils.unwrap_angle(rotation - external_force_angle)
	
	var animation_key = choose_animation_direction(stagger_angle, STAGGER_F_ANIM_KEY, STAGGER_L_ANIM_KEY, STAGGER_B_ANIM_KEY, STAGGER_R_ANIM_KEY)
	
	if(animation_player.has_animation(animation_key)):
		animation_player.play(animation_key)
	
var death_angle : float = 0

func begin_state_death():
	# disable_collisions
	state = STATE.DEAD
	set_collision_layer(0)
	set_z_index(-1)
	
	var external_force_angle : float = (get_force(TYPE.EXTERNAL) + get_impulse(TYPE.EXTERNAL)).angle()
	death_angle = Utils.unwrap_angle(rotation - external_force_angle)
	
	# spawn pre-death effects
	for effect_scene in pre_death_effects:
		var effect_attributes := {
			"source" : self,
			"rotation" : rotation,
			"position" : global_position,
			"effect_angle" : death_angle
		}
		SignalBus.spawn_effect.emit(effect_scene.get_path(), effect_attributes)
	
	var death_animation = choose_animation_direction(death_angle, DEATH_F_ANIM_KEY, DEATH_L_ANIM_KEY, DEATH_B_ANIM_KEY, DEATH_R_ANIM_KEY)
	
#	var death_animation = DEATH_ANIM_KEY
#	var death_angles = {}
#	if(animation_player.has_animation(DEATH_F_ANIM_KEY)):
#		death_angles[DEATH_F_ANIM_KEY] = 0
#	if(animation_player.has_animation(DEATH_L_ANIM_KEY)):
#		death_angles[DEATH_L_ANIM_KEY] = PI/2
#	if(animation_player.has_animation(DEATH_B_ANIM_KEY)):
#		death_angles[DEATH_B_ANIM_KEY] = PI
#	if(animation_player.has_animation(DEATH_R_ANIM_KEY)):
#		death_angles[DEATH_R_ANIM_KEY] = 3*(PI/2)
#
#	if(death_angles.size() > 0):
#		var min_angle : float = 9999
#		for key in death_angles.keys():
#			var angle = death_angles[key]
#			var dif = abs(angle - death_angle)
#			if(dif > PI):
#				dif = TAU - dif
#			if(dif < min_angle):
#				min_angle = dif
#				death_animation = key
	
	if(animation_player.has_animation(death_animation)):
		# trigger death animation
		# animation_player.get_animation(death_animation).set_loop_mode(Animation.LOOP_NONE)
		animation_player.play(death_animation)
	else:
		end_state_death()

func _on_animation_finished(anim_name: StringName):
	if(String(anim_name).begins_with(DEATH_ANIM_KEY)):
		end_state_death()

func end_state_death():
	# spawn post-death effects
	for effect_scene in post_death_effects:
		var effect_attributes := {
			"source" : self,
			"rotation" : rotation,
			"position" : global_position,
			"effect_angle" : death_angle
		}
		SignalBus.spawn_effect.emit(effect_scene.get_path(), effect_attributes)
	
	#TODO: fix corpse effect spawn in, this timer is a bandaid to avoid flickering when corpse is spawned
	await(get_tree().create_timer(0.1).timeout)
	queue_free()

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

func set_nav_controller(_nav_controller : NavigationController) -> void:
	nav_controller = _nav_controller

func get_nav_controller() -> NavigationController:
	return nav_controller

func _on_attack_collision(_attack_data: Dictionary):
	var hit_angle = _attack_data.get(AttackConsts.ANGLE)
	var hit_force = _attack_data.get(AttackConsts.FORCE)
	var hit_damage = _attack_data.get(AttackConsts.DAMAGE)
	
	if(hit_damage is float):
		health -= hit_damage
	
	if(hit_angle != null && hit_force != null):
		apply_impulse(Vector2.from_angle(hit_angle) * hit_force, TYPE.EXTERNAL)
		set_force(Vector2.ZERO, TYPE.MANUAL)
		set_velocity_type(Vector2.ZERO, TYPE.MANUAL)
		apply_hitstun(0.5)

func choose_animation_direction(
	angle : float, anim_f : String, anim_l : String, anim_b : String, anim_r : String, anim_def : String = "") -> String:
	var animation_key : String = anim_def
	if(animation_key == null || animation_key == ""):
		animation_key = anim_f
	var animation_angles = {}
	if(animation_player.has_animation(anim_f)):
		animation_angles[anim_f] = 0
	if(animation_player.has_animation(anim_l)):
		animation_angles[anim_l] = PI/2
	if(animation_player.has_animation(anim_b)):
		animation_angles[anim_b] = PI
	if(animation_player.has_animation(anim_r)):
		animation_angles[anim_r] = 3*(PI/2)
	
	if(animation_angles.size() > 0):
		var min_angle : float = 9999
		for key in animation_angles.keys():
			var animation_angle = animation_angles[key]
			var dif = abs(animation_angle - angle)
			if(dif > PI):
				dif = TAU - dif
			if(dif < min_angle):
				min_angle = dif
				animation_key = key
	
	return animation_key
