class_name SteeringComponent2D
extends Node2D

enum STEER_TYPE {NULL=0, ACTIVE, PASSIVE}

var parent : CharacterBody2D
var steering_force : Vector2

@export var steering_magnitude : float = 1.0
@export var calculation_cooldown : int = 0
var last_calculation : int = 0

var running : bool = true

func _ready() -> void:
	steering_force = Vector2.ZERO
	parent = get_parent()

func steer() -> Vector2:
	if(!running):
		return Vector2.ZERO
	
	if(calculation_cooldown == 0 || (Time.get_ticks_msec() - last_calculation) > calculation_cooldown):
		if(!is_equal_approx(steering_magnitude, 0)):
			last_calculation = Time.get_ticks_msec()
			calculate_steering_force()
	
	return steering_magnitude * steering_force

func get_steer_type() -> int:
	return STEER_TYPE.NULL

func calculate_steering_force():
	pass

func draw():
	pass
