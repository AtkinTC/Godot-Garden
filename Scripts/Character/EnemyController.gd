class_name EnemyController
extends Node2D

@onready var parent_body : CharacterBody2DCust

var nav_controller : NavigationController

var target_position : Vector2
var seek_target_position : Vector2

var setup_params : Dictionary = {}

@export var animation_player : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_body = self.get_parent()
	setup_params = parent_body.get_setup_params()

	set_nav_controller(setup_params.get("nav_controller", nav_controller))

var last_animation_change_time : int = 0

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var v = get_body_velocity()
	var s = v.length()
	
	if(last_animation_change_time == 0 || Time.get_ticks_msec() - last_animation_change_time > 500):
		var desired_animation : String = "idle"
		
		if(s < 1):
			desired_animation = "idle"
		elif(s < 20):
			desired_animation = "walk"
		else:
			desired_animation = "run"
		
		if(animation_player.has_animation(desired_animation) && animation_player.get_current_animation() != desired_animation):
			animation_player.play(desired_animation)
			last_animation_change_time = Time.get_ticks_msec()

func set_nav_controller(_nav_controller : NavigationController) -> void:
	nav_controller = _nav_controller

func get_nav_controller() -> NavigationController:
	return nav_controller

func set_body_position(_position : Vector2) -> void:
	parent_body.set_position(_position)

func get_body_position() -> Vector2:
	return parent_body.get_position()

func set_body_velocity(_velocity : Vector2):
	parent_body.set_velocity(_velocity)

func get_body_velocity() -> Vector2:
	return parent_body.get_velocity()

func reset_body_slide_collision_count() -> void:
	parent_body.reset_cumulative_slide_collision_count()

func get_body_slide_collision_count() -> int:
	return parent_body.get_cumulative_slide_collision_count()
	
func set_target_position(_target_position : Vector2) -> void:
	target_position = _target_position

func get_target_position() -> Vector2:
	return target_position

func set_seek_target_position(_seek_target_position : Vector2):
	seek_target_position = _seek_target_position

func get_seek_target_position() -> Vector2:
	return seek_target_position

func get_body_collision_layer() -> int:
	return parent_body.get_collision_layer()

