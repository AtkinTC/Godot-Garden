class_name Enemy
extends CharacterBody2D

@onready var sprite_node: Node2D = get_node("Sprite")

var steering_vector := Vector2.ZERO
var max_speed := 50.0
var move_vector := Vector2.ZERO

var target_position := Vector2.ZERO
var practical_target_position := Vector2.ZERO

var facing_direction := Vector2.RIGHT

var nav_controller : Navigation

var seek_steering : SeekSteering
var wander_steering : WanderSteering
var wall_avoid_steering : WallSeperationSteering
var seperation_steering : SeperationSteering

@onready var hurtbox: Hurtbox = get_node_or_null("Hurtbox")

func set_params(params : Dictionary):
	position = params.get("position", position)
	nav_controller = params.get("nav_controller", nav_controller)
	
	seek_steering = SeekSteering.new(max_speed)
	wander_steering = WanderSteering.new(max_speed,max_speed,0.5)
	wall_avoid_steering = WallSeperationSteering.new(nav_controller, 20, 8)
	seperation_steering = SeperationSteering.new(16, 8)

func _ready() -> void:
	target_position = position
	
	if(hurtbox is Hurtbox):
		hurtbox.connect_hit(_on_Hurtbox_took_hit)

var wander_force := 0.25
var seek_force := 1.0
var seperation_force := 3.0
var wall_avoid_force := 2.0

var wander_vector := Vector2.ZERO
var seek_vector := Vector2.ZERO
var seperation_vector := Vector2.ZERO
var wall_avoid_vector := Vector2.ZERO

var seperation_cooldown_limit := 0.03
var seperation_cooldown := 0.0

func _process(delta: float) -> void:
	# gradually remove tint after taking a hit
	var sprite_material: Material = sprite_node.material
#	if(sprite_material is Material):
#		var tint_color = lerp(sprite_material.get_shader_param("TINT_COLOR"), Color.WHITE, 0.2)
#		sprite_material.set_shader_param("TINT_COLOR", tint_color)
	
	update()

func _physics_process(delta: float) -> void:
	process_knockback(delta)
	
	practical_target_position = get_practical_target()
	
	if(!knockback_state):
		wander_vector = Vector2.ZERO #wander_steering.steer(facing_direction)
		seek_vector = seek_steering.steer(position, practical_target_position, move_vector)
	else:
		wander_vector = Vector2.ZERO
		seek_vector = Vector2.ZERO
		
	if(seperation_cooldown <= 0):
		seperation_vector = seperation_steering.steer(self)
		seperation_cooldown = seperation_cooldown_limit
	else:
		seperation_cooldown -= delta
	wall_avoid_vector = wall_avoid_steering.steer(self)
	
	steering_vector = Vector2.ZERO
	steering_vector += wander_vector * wander_force
	steering_vector += seperation_vector * seperation_force
	steering_vector += seek_vector * seek_force
	steering_vector += wall_avoid_vector * wall_avoid_force
	
	steering_vector = steering_vector.limit_length(max_speed) * max_speed
	
	var max_speed_vector = move_vector * max_speed
	var max_speed_temp = max_speed_vector.length()
	if(move_vector.length() > max_speed):
		var excess = move_vector.length() - max_speed
		move_vector *= (1.0 - (excess/max_speed) * 2.0 * delta)
	move_vector += steering_vector * delta 

	velocity = move_vector + get_knockback()
	move_and_slide()
	
	#end knockback if collided
	if(get_slide_collision_count() > 0 && knockback_state):
		set_knockback(0.0)
	
	if(move_vector != Vector2.ZERO):
		facing_direction = move_vector.normalized()

func _draw() -> void:
	#draw_line(Vector2.ZERO, (practical_target_position - position).normalized() * max_speed, Color.blue, 2)
	#draw_line(Vector2.ZERO, seek_vector * max_speed, Color.red, 2)
	#draw_line(Vector2.ZERO, move_vector, Color.green, 2)
	
	#seek_steering.draw(self)
	#wander_steering.draw(self, Color.RED)
	#wall_avoid_steering.draw(self, Color.RED)
	#seperation_steering.draw(self)
	pass

var min_target_distance := 20.0
func get_practical_target() -> Vector2:
	if(position.distance_squared_to(target_position) < min_target_distance):
		#target already reached
		return position
	
	var bit := PhysicsUtil.get_physics_layer_bit("wall")
	
	var wall_collision_mask = PhysicsUtil.get_physics_layer_mask([PhysicsUtil.get_physics_layer_bit("wall")])
	var params := PhysicsRayQueryParameters2D.new()
	params.collision_mask = wall_collision_mask
	params.from = position
	params.to = target_position
	var result = get_world_2d().direct_space_state.intersect_ray(params)
	
	if(result is Dictionary && result.size() > 0):
		#wall in the direct line to the target, will use pathfinding instead
		var flow_vector := nav_controller.get_flow_direction(position, target_position)
		return position + flow_vector * max_speed
	
	return target_position

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
	
