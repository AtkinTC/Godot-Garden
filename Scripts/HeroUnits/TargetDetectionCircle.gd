class_name TargetDetectionCircle

extends Area2D

signal targets_changed()

@export var include_groups : Array[String] = []
@export var exclude_groups : Array[String] = []
@export var detection_range : float = 50: set = set_detection_range

@onready var collision_node : CollisionShape2D = get_node("CollisionShape2D")
@onready var detection_circle : CircleShape2D

var target_ids : Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	
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

func is_valid_target(body: Node2D) -> bool:
	return target_ids.has(body.get_instance_id())

func update_targets() -> void:
	targets_changed.emit()

func _on_body_entered(body: Node2D) -> void:
	for group in exclude_groups:
		if(body.is_in_group(group)):
			# explicitly excluded
			return
	
	if(include_groups.size() == 0):
		add_target(body)
		return
		
	for group in include_groups:
		if(body.is_in_group(group)):
			# explicitly included
			add_target(body)
			return

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
	
	var global_p = global_position + local_point
	
	var closest_body : Node2D = null
	var min_dist_sqr : float = 999999.99
	var closest_body_pref : Node2D = null
	var min_dist_sqr_pref : float = 999999.99
	var pref_limit_sqr = preferred_limit * preferred_limit
	
	for id in target_ids:
		var body : Node2D = instance_from_id(id)
		if(!body):
			continue
		var dist = global_p.distance_squared_to(body.get_global_position())
		if(pref_limit_sqr > 0 && global_position.distance_squared_to(body.get_global_position()) <= pref_limit_sqr):
			if(dist < min_dist_sqr_pref):
				min_dist_sqr_pref = dist
				closest_body_pref = body
		if(dist < min_dist_sqr):
			min_dist_sqr = dist
			closest_body = body
	
	return closest_body_pref if (closest_body_pref != null) else closest_body
