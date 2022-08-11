class_name Enemy
extends EnemyBody2D

@export var health_max : int = 1
@onready var health : float = health_max

@export var death_effect_scene : PackedScene

var seek_target_position : Vector2

@onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

var last_animation_change_time : int = 0

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	super._process(_delta)
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
		on_death()
	else:
		super._physics_process(_delta)

func on_death():
	if(death_effect_scene):
		var effect_attributes := {
			"source" : self,
			"rotation" : facing_rotation,
			"position" : global_position
		}
		SignalBus.spawn_effect.emit(death_effect_scene.get_path(), effect_attributes)
	queue_free()

func set_nav_controller(_nav_controller : NavigationController) -> void:
	nav_controller = _nav_controller

func get_nav_controller() -> NavigationController:
	return nav_controller

func _on_attack_collision(_attack_data: Dictionary):
	var hit_position = _attack_data.get(AttackConsts.POSITION)
	var hit_angle = _attack_data.get(AttackConsts.ANGLE)
	var hit_force = _attack_data.get(AttackConsts.FORCE)
	
	apply_impulse(Vector2.from_angle(hit_angle) * hit_force, TYPE.EXTERNAL)
	set_force(Vector2.ZERO, TYPE.MANUAL)
	set_velocity_type(Vector2.ZERO, TYPE.MANUAL)
	apply_hitstun(1)
	
	health -= 1
