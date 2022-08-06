class_name InputHandler
extends Node2D

@onready var player: Player = get_parent()

var right_input : float = 0
var left_input : float = 0
var up_input : float = 0
var down_input : float = 0

var right_pressed := false
var left_pressed := false
var up_pressed := false
var down_pressed := false
var select_pressed := false

var input_axis : Vector2 = Vector2.ZERO

var aim_position : Vector2 = Vector2.ZERO

var world : World

func _init() -> void:
	pass

func _ready() -> void:
	world = get_tree().get_first_node_in_group("world")

func _physics_process(delta: float) -> void:
	input_axis = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	
	right_input = Input.get_action_strength("ui_right")
	left_input = Input.get_action_strength("ui_right")
	up_input = Input.get_action_strength("ui_right")
	down_input = Input.get_action_strength("ui_right")
		
	player.set_input_steering_vector(input_axis)
	
	aim_position = get_global_mouse_position()
	
	player.set_imput_aim_position(aim_position)
	
#	if(select_pressed):
#		player.set_attack_input()
#		select_pressed = false
	

func _unhandled_input(event: InputEvent) -> void:
	check_inputs()

func check_inputs() -> void:
	if(Input.is_action_just_pressed("ui_right") || Input.is_action_pressed("ui_right")):
		right_pressed = true
	else:
		right_pressed = false
	
	if(Input.is_action_just_pressed("ui_left") || Input.is_action_pressed("ui_left")):
		left_pressed = true
	else:
		left_pressed = false
	
	if(Input.is_action_just_pressed("ui_down") || Input.is_action_pressed("ui_down")):
		down_pressed = true
	else:
		down_pressed = false
	
	if(Input.is_action_just_pressed("ui_up") || Input.is_action_pressed("ui_up")):
		up_pressed = true
	else:
		up_pressed = false
	
	if(Input.is_action_pressed("ui_select")):
		select_pressed = true
