class_name AgentBody2D
extends CharacterBody2D

enum TYPE {MANUAL, EXTERNAL}

@export var mass : float = 1
@export var max_speed : float = 100
@export var damp_manual : float = 1.0
@export var damp_external : float = 4.0
@export var max_rotation_speed : float = TAU
@export var damp_rotation_manual : float = 1.0
@export var damp_rotation_external: float = 4.0
@export var body_radius : int = 0

var force_manual := Vector2.ZERO
var force_external := Vector2.ZERO

var impulse_manual := Vector2.ZERO
var impulse_external := Vector2.ZERO

var velocity_manual := Vector2.ZERO
var velocity_external := Vector2.ZERO

var rotation_force_manual : float = 0
var rotation_force_external : float = 0

var rotation_impulse_manual : float = 0
var rotation_impulse_external : float = 0

var rotation_speed_manual : float = 0
var rotation_speed_external : float = 0

var rotation_speed : float = 0
var facing_rotation : float = 0

func _physics_process(delta: float) -> void:
	# apply forces
	rotation_speed_manual += (rotation_force_manual * delta + rotation_impulse_manual) / mass
	rotation_speed_external += (rotation_force_external * delta + rotation_impulse_external) / mass
	velocity_manual += (force_manual * delta + impulse_manual) / mass
	velocity_external += (force_external * delta + impulse_external) / mass
	
	rotation_speed = clampf(rotation_speed_manual, -max_rotation_speed, max_rotation_speed)
	rotation_speed += rotation_speed_external
	velocity = velocity_manual.limit_length(max_speed)
	velocity += velocity_external
	
	# reset impulses
	rotation_impulse_manual = 0
	rotation_impulse_external = 0
	impulse_manual = Vector2.ZERO
	impulse_external = Vector2.ZERO
	
	# apply rotation
	facing_rotation += rotation_speed * delta
	facing_rotation = Utils.unwrap_angle(facing_rotation)
	
	# apply velocity
	move_and_slide()
	if(get_slide_collision_count() > 0):
		velocity_external = Vector2.ZERO
	
	rotation_speed_manual *= max(1.0 - damp_rotation_manual * delta, 0.0) as float
	rotation_speed_external *= max(1.0 - damp_rotation_external * delta, 0.0) as float
	velocity_manual *= max(1.0 - damp_manual * delta, 0.0) as float
	velocity_external *= max(1.0 - damp_external * delta, 0.0) as float

###################
# GETTERS/SETTERS #
###################

func get_max_speed() -> float:
	return max_speed

func set_force(_force: Vector2, force_type := TYPE.MANUAL) -> void:
	if(force_type == TYPE.MANUAL):
		force_manual = _force
	if(force_type == TYPE.EXTERNAL):
		force_external = _force

func apply_force(_force: Vector2, force_type := TYPE.MANUAL) -> void:
	if(force_type == TYPE.MANUAL):
		force_manual += _force
	if(force_type == TYPE.EXTERNAL):
		force_external += _force

func set_impulse(_impulse: Vector2, impulse_type := TYPE.MANUAL) -> void:
	if(impulse_type == TYPE.MANUAL):
		impulse_manual = _impulse
	if(impulse_type == TYPE.EXTERNAL):
		impulse_external = _impulse

func apply_impulse(_impulse: Vector2, impulse_type := TYPE.MANUAL) -> void:
	if(impulse_type == TYPE.MANUAL):
		impulse_manual += _impulse
	if(impulse_type == TYPE.EXTERNAL):
		impulse_external += _impulse

func set_velocity_type(_velocity: Vector2, velocity_type := TYPE.MANUAL):
	if(velocity_type == TYPE.MANUAL):
		velocity_manual += _velocity
	if(velocity_type == TYPE.EXTERNAL):
		velocity_manual += _velocity

func set_facing_direction(_facing_direction: Vector2) -> void:
	facing_rotation = _facing_direction.angle()

func get_facing_direction() -> Vector2:
	return Vector2.from_angle(facing_rotation)

func get_body_radius() -> int:
	return body_radius
