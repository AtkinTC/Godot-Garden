class_name Player
extends CharacterBody2D

enum STATE {IDLE, WALK, RUN, START_ATTACK, ATTACK}

var state = STATE.IDLE

var input_steering_vector := Vector2.ZERO
var attack_input := false
var speed := 150
var move_vector := Vector2.ZERO
var facing_vector := Vector2.RIGHT
var facing_angle_index: int = 2

var input_aim_position := Vector2.ZERO
var aim_position := Vector2.ZERO

@export var animation_player: AnimationPlayer
@export var rotation_node: Node2D

func _ready() -> void:
	#animation_player.play("Idle_2")
	pass

func _process(delta: float) -> void:
#	if(state == STATE.IDLE):
#		var animation_name = str("Idle_", facing_angle_index)
#		if(animation_player.has_animation(animation_name) && animation_player.current_animation != animation_name):
#			animation_player.play(animation_name)
	pass

func _physics_process(delta: float) -> void:
	var target_move_vector = input_steering_vector.normalized() * speed
	move_vector = Tween.interpolate_value(move_vector, target_move_vector - move_vector, delta, 0.8, Tween.TRANS_QUINT,Tween.EASE_OUT)
	#move_vector = input_steering_vector.normalized() * speed
	velocity = move_vector
	move_and_slide()
	
	var local_aim_target := input_aim_position - position
	var target_angle := local_aim_target.angle()
	var current_angle := facing_vector.angle()
	if(target_angle - current_angle > PI):
		current_angle += TAU
	if(current_angle - target_angle  > PI):
		target_angle += TAU
	print(str("target = ", target_angle, ", current = ", current_angle))
	var new_angle : float = Tween.interpolate_value(current_angle, target_angle - current_angle, delta, 0.8, Tween.TRANS_QUINT,Tween.EASE_OUT)
	facing_vector = Vector2.from_angle(new_angle)
	rotation_node.set_rotation(new_angle)
	aim_position = Tween.interpolate_value(aim_position, local_aim_target - aim_position, delta, 0.8, Tween.TRANS_QUINT,Tween.EASE_OUT)
	
	
	
#	var facing_angle = rad2deg(facing_vector.angle())+22.5
#	if(facing_angle < 0):
#		facing_angle += 360
#	facing_angle_index = floor(facing_angle/45)
	
#	if(state == STATE.IDLE && attack_input):
#		attack_input = false
#		var animation_name = str("Attack_", facing_angle_index)
#		if(!animation_player.has_animation(animation_name)):
#			state = STATE.IDLE
#		elif(animation_player.current_animation != animation_name):
#			animation_player.play(animation_name)
#			state = STATE.ATTACK
	
	#update()

func set_input_steering_vector(_input_steering_vector: Vector2):
	input_steering_vector = _input_steering_vector

func get_input_steering_vector():
	return input_steering_vector

func set_imput_aim_position(_input_aim_position : Vector2):
	input_aim_position = _input_aim_position

func get_input_aim_position() -> Vector2:
	return input_aim_position

func get_aim_position() -> Vector2:
	return aim_position

func set_attack_input(_input: bool = true):
	attack_input = _input

func _draw() -> void:
	pass
	#if(steering_vector != Vector2.ZERO):
		#draw_line(Vector2.ZERO, move_vector, Color.red, 2)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if(state == STATE.ATTACK):
		state = STATE.IDLE
