# TargetDetectionCircle extends Area2D
#	monitors targets entering/exiting area
#	with utility functions to access/organize those targets

@tool
class_name TargetDetectionCircle
extends Area2D

signal targets_changed()

@export var include_groups : Array[String] = []
@export var exclude_groups : Array[String] = []
@export var detection_range : float = 50: set = set_detection_range

var collision_node : CollisionShape2D
var detection_circle : CircleShape2D

var blocker_layers : Array[String] = ["wall"]
@onready var blocker_mask := PhysicsUtil.get_physics_layer_mask_from_names(blocker_layers)

var target_ids : Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	
	set_collision_layer(0)
	set_monitoring(true)
	set_monitorable(false)
	
	collision_node = CollisionShape2D.new()
	add_child(collision_node)
	
	detection_circle = CircleShape2D.new()
	detection_circle.set_radius(detection_range)
	collision_node.set_shape(detection_circle)

func set_detection_range(_detection_range : float) -> void:
	if(is_equal_approx(detection_range, _detection_range)):
		return
	detection_range = _detection_range
	if(detection_circle):
		detection_circle.set_radius(detection_range)

func add_target(body: Node2D) -> bool:
	var instance_id := body.get_instance_id()
	if(target_ids.has(instance_id)):
		return false
	
	var exclude := false
	for group in exclude_groups:
		if(body.is_in_group(group)):
			# explicitly excluded
			exclude = true
			break
	if(exclude):
		return false
	
	var include := false
	if(include_groups.size() == 0):
		include = true
	else:
		for group in include_groups:
			if(body.is_in_group(group)):
				# explicitly included
				include = true
				break
	if(!include):
		return false
	
	var i := target_ids.bsearch(instance_id)
	target_ids.insert(i, instance_id)
	body.tree_exiting.connect(remove_target.bind(body))
	update_targets()
	return true

func remove_target(body: Node2D) -> bool:
	var instance_id := body.get_instance_id()
	if(!target_ids.has(instance_id)):
		return false
	var i := target_ids.bsearch(instance_id)
	target_ids.remove_at(i)
	
	if(body.tree_exiting.is_connected(remove_target)):
		body.tree_exiting.disconnect(remove_target)
	
	update_targets()
	return true

func is_valid_target(body: Node2D, check_los := true) -> bool:
	if(body == null):
		return false
	
	if(!target_ids.has(body.get_instance_id())):
		return false
	
	if(check_los && !is_in_los(body)):
		return false
	
	return true

func is_in_los(body: Node2D) -> bool:
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().get_direct_space_state()

	var ray_query = PhysicsRayQueryParameters2D.new()
	ray_query.from = global_position
	ray_query.to = body.global_position
	ray_query.collision_mask = blocker_mask
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = true
	ray_query.hit_from_inside = true
	
	var collision : Dictionary = space_state.intersect_ray(ray_query)
	if(collision.is_empty()):
		return true
	return false

func update_targets() -> void:
	targets_changed.emit()

func _on_body_entered(body: Node2D) -> void:
	add_target(body)

func _on_body_exited(body: Node2D) -> void:
	remove_target(body)

func get_closest_target() -> Node2D:
	if(target_ids.size() == 0):
		return null
	
	var closest_body : Node2D = null
	var min_dist_sqr : float = 999999.99
	
	for id in target_ids:
		var body : Node2D = instance_from_id(id)
		if(!body):
			continue
		var dist = global_position.distance_squared_to(body.get_global_position())
		if(dist < min_dist_sqr):
			min_dist_sqr = dist
			closest_body = body
	
	return closest_body

# returns the target closest to the provided local point or null if there are no targets
# 	if the optional preferred_limit is provided, it gives priority to targets within that distance from the origin
#	this can be useful to prioritize targets that are within some smaller radius inside the detection range
func get_closest_target_to_point(local_point : Vector2, preferred_limit : float = 0.0):
	if(target_ids.size() == 0):
		return null
	
	var pref_limit_sqr = preferred_limit * preferred_limit
	
	var sorted_bodies : Array[Node2D] = []
	var sorted_dist_sqr : Array[float] = []
	var sorted_bodies_pref : Array[Node2D] = []
	var sorted_dist_sqr_pref : Array[float] = []
	
	for id in target_ids:
		var body : Node2D = instance_from_id(id)
		if(!body):
			continue
		
		var dist_sqr = (global_position + local_point).distance_squared_to(body.get_global_position())
		if(pref_limit_sqr > 0 && global_position.distance_squared_to(body.get_global_position()) <= pref_limit_sqr):
			# add to sorted list of preferred targets
			var i : int = sorted_dist_sqr_pref.bsearch(dist_sqr)
			sorted_dist_sqr_pref.insert(i, dist_sqr)
			sorted_bodies_pref.insert(i, body)
		else:
			# add to sorted list of other targets
			var i : int = sorted_dist_sqr.bsearch(dist_sqr)
			sorted_dist_sqr.insert(i, dist_sqr)
			sorted_bodies.insert(i, body)
	
	# check line-of-sight for each preferred targets until one passes
	for body in sorted_bodies_pref:
		if(is_in_los(body)):
			return body
	
	## check line-of-sight for each other targets until one passes
	for body in sorted_bodies:
		if(is_in_los(body)):
			return body
	
	return null

# block configuration warnings for this node
func _get_configuration_warning():
	return ""
