class_name Enemy
extends CharacterBody2D

@onready var sprite_node: Node2D = get_node("Sprite")

var steering_vector := Vector2.ZERO
@export var max_speed : float = 50.0
var move_vector := Vector2.ZERO

var target_position := Vector2.ZERO
var practical_target_position := Vector2.ZERO

var facing_direction := Vector2.RIGHT

var nav_controller : Navigation

@onready var hurtbox: Hurtbox = get_node_or_null("Hurtbox")

func set_params(params : Dictionary):
	position = params.get("position", position)
	nav_controller = params.get("nav_controller", nav_controller)
	facing_direction = params.get("facing_direction", facing_direction)

func _ready() -> void:
	target_position = position
	
	if(hurtbox is Hurtbox):
		hurtbox.connect_hit(_on_Hurtbox_took_hit)
	
	attach_steering_components()

var steering_components : Array[SteeringComponent2D]

func attach_steering_components():
	steering_components = []
	for child in get_children():
		if(child is SteeringComponent2D):
			steering_components.append(child)

func _process(delta: float) -> void:
	# gradually remove tint after taking a hit
	var sprite_material: Material = sprite_node.material
#	if(sprite_material is Material):
#		var tint_color = lerp(sprite_material.get_shader_param("TINT_COLOR"), Color.WHITE, 0.2)
#		sprite_material.set_shader_param("TINT_COLOR", tint_color)
	
	sprite_node.set_rotation(facing_direction.angle())
	
	update()

func _physics_process(delta: float) -> void:
	process_knockback(delta)
	
	update_practical_target()
	
	# sum up different steering components
	var passive_steering := Vector2.ZERO
	var active_steering := Vector2.ZERO
	var other_steering := Vector2.ZERO
	for steering_component in steering_components:
		if(steering_component.get_steer_type() == steering_component.STEER_TYPE.PASSIVE):
			passive_steering += steering_component.steer()
		elif(steering_component.get_steer_type() == steering_component.STEER_TYPE.ACTIVE):
			active_steering += steering_component.steer()
		else:
			other_steering += steering_component.steer()
	
	steering_vector = Vector2.ZERO
	steering_vector += passive_steering
	steering_vector += other_steering
	if(!knockback_state):
		steering_vector += active_steering
	
	steering_vector = steering_vector.limit_length(max_speed) * max_speed
	
	var max_speed_vector = move_vector * max_speed
	var max_speed_temp = max_speed_vector.length()
	if(move_vector.length() > max_speed):
		var excess = move_vector.length() - max_speed
		move_vector *= (1.0 - (excess/max_speed) * 2.0 * delta)
	move_vector += steering_vector * delta 

	velocity = move_vector + get_knockback()
	move_and_slide()
	
	if(!move_vector.is_equal_approx(Vector2.ZERO) && !knockback_state):
		facing_direction = move_vector.normalized()
	
	#end knockback if collided
	if(get_slide_collision_count() > 0 && knockback_state):
		set_knockback(0.0)

func _draw() -> void:
	#draw_line(Vector2.ZERO, (practical_target_position - position).normalized() * max_speed, Color.blue, 2)
	#draw_line(Vector2.ZERO, move_vector, Color.green, 2)
	
	#for steering_component in steering_components:
	#	steering_component.draw()
	pass

var min_target_distance := 20.0
# 
func update_practical_target():
	if(position.distance_squared_to(target_position) < min_target_distance):
		#target already reached
		practical_target_position = position
		return
	
	var physics_layer_bit := PhysicsUtil.get_physics_layer_bit("wall")
	var wall_collision_mask = PhysicsUtil.get_physics_layer_mask([physics_layer_bit])
	var params := PhysicsRayQueryParameters2D.new()
	params.collision_mask = wall_collision_mask
	params.from = position
	params.to = target_position
	var result = get_world_2d().direct_space_state.intersect_ray(params)
	
	if(result is Dictionary && result.size() > 0):
		#wall in the direct line to the target, will use pathfinding instead
		var flow_vector := nav_controller.get_flow_direction(position, target_position)
		practical_target_position = position + flow_vector * max_speed
		return
	
	practical_target_position = target_position

func set_target_position(_target_position : Vector2):
	target_position = _target_position

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

func get_target_position() -> Vector2:
	return target_position

func get_seek_target_position() -> Vector2:
	return practical_target_position

func get_max_speed() -> float:
	return max_speed

func get_facing_direction() -> Vector2:
	return facing_direction

func _on_Hurtbox_took_hit(source: Hurtbox, hit_data: Dictionary):
	if(hit_data.has("damage")):
		#apply a red tint on taking damage
		var sprite_material: Material = sprite_node.material
		if(sprite_material is Material):
			sprite_material.set_shader_param("TINT_COLOR", Color.RED)
	
	if(hit_data.has("knockback")):
		var knockback_data: Dictionary = hit_data["knockback"]
		var impulse = knockback_data.get("impulse")
		var direction = knockback_data.get("direction")
		set_knockback(impulse, direction)
	
