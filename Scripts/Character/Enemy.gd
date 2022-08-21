class_name Enemy
extends EnemyBody2D

const DEATH_ANIM_KEY = "death"
const DEATH_F_ANIM_KEY = DEATH_ANIM_KEY + "_front"
const DEATH_B_ANIM_KEY = DEATH_ANIM_KEY + "_back"
const DEATH_R_ANIM_KEY = DEATH_ANIM_KEY + "_right"
const DEATH_L_ANIM_KEY = DEATH_ANIM_KEY + "_left"

enum STATE {NULL, DEFAULT, DEAD}

var state = STATE.NULL

@export var health_max : int = 1
@onready var health : float = health_max

@export var pre_death_effects : Array[PackedScene]
@export var post_death_effects : Array[PackedScene]

var seek_target_position : Vector2

@onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	animation_player.animation_finished.connect(_on_animation_finished)
	state = STATE.DEFAULT

var last_animation_change_time : int = 0

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	super._process(_delta)
	if(state != STATE.DEAD):
		var v = velocity
		var s = v.length()
		
		if(last_animation_change_time == 0 || Time.get_ticks_msec() - last_animation_change_time > 500):
			var desired_animation : String = "idle"
			
			if(s < 1):
				desired_animation = "idle"
			elif(s < 15):
				desired_animation = "walk"
			else:
				desired_animation = "run"
			
			if(animation_player.has_animation(desired_animation) && animation_player.get_current_animation() != desired_animation):
				animation_player.play(desired_animation)
				last_animation_change_time = Time.get_ticks_msec()

func _physics_process(_delta: float) -> void:
	if(health <= 0):
		if(state != STATE.DEAD):
			state = STATE.DEAD
			begin_death()
	else:
		super._physics_process(_delta)

var death_angle : float = 0

func begin_death():
	# disable_collisions
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
	
	var death_animation = DEATH_ANIM_KEY
	var death_angles = {}
	if(animation_player.has_animation(DEATH_F_ANIM_KEY)):
		death_angles[DEATH_F_ANIM_KEY] = 0
	if(animation_player.has_animation(DEATH_L_ANIM_KEY)):
		death_angles[DEATH_L_ANIM_KEY] = PI/2
	if(animation_player.has_animation(DEATH_B_ANIM_KEY)):
		death_angles[DEATH_B_ANIM_KEY] = PI
	if(animation_player.has_animation(DEATH_R_ANIM_KEY)):
		death_angles[DEATH_R_ANIM_KEY] = 3*(PI/2)
	
	if(death_angles.size() > 0):
		var min_angle : float = 9999
		for key in death_angles.keys():
			var angle = death_angles[key]
			var dif = abs(angle - death_angle)
			if(dif > PI):
				dif = TAU - dif
			if(dif < min_angle):
				min_angle = dif
				death_animation = key
	
	animation_player.play(death_animation)
	
	if(animation_player.has_animation(death_animation)):
		# trigger death animation
		animation_player.get_animation(death_animation).set_loop_mode(Animation.LOOP_NONE)
		animation_player.play(death_animation)
	else:
		complete_death()

func _on_animation_finished(anim_name: StringName):
	if(String(anim_name).begins_with(DEATH_ANIM_KEY)):
		complete_death()

func complete_death():
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

func set_nav_controller(_nav_controller : NavigationController) -> void:
	nav_controller = _nav_controller

func get_nav_controller() -> NavigationController:
	return nav_controller

func _on_attack_collision(_attack_data: Dictionary):
	var hit_angle = _attack_data.get(AttackConsts.ANGLE)
	var hit_force = _attack_data.get(AttackConsts.FORCE)
	
	apply_impulse(Vector2.from_angle(hit_angle) * hit_force, TYPE.EXTERNAL)
	set_force(Vector2.ZERO, TYPE.MANUAL)
	set_velocity_type(Vector2.ZERO, TYPE.MANUAL)
	apply_hitstun(1)
	
	health -= 1
