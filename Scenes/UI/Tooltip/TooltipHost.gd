extends Node
class_name TooltipHost

enum Direction {RIGHT = 1, LEFT = 2, TOP = 4, BOTTOM = 8, BOTTOM_RIGHT = 9, BOTTOM_LEFT = 10, TOP_RIGHT = 5, TOP_LEFT = 6, CENTER = 0}
@export var direction : Direction = Direction.RIGHT
@export var alignment : Direction = Direction.CENTER

@export var canvas_layer_path : String 
@export var tooltip_scene: PackedScene
@export_node_path(Node) var owner_path: NodePath
@export_range(0, 10, 0.05) var open_delay : float = 0.5
@export_range(0, 10, 0.05) var close_delay : float = 0.5
@export var follow_mouse: bool = true
@export_range(0, 100, 1) var offset_x : float
@export_range(0, 100, 1) var offset_y : float
@export var offset_relative : bool = true
@export_range(0, 100, 1) var padding_x : float
@export_range(0, 100, 1) var padding_y : float

var _tooltip: Control
var _timer: Timer
var _mouse_inside_owner : bool
var _mouse_inside_tooltip : bool
var _mouseover_updated : bool
var _force_close : bool
var _force_open : bool

@onready var owner_node = get_node_or_null(owner_path)
@onready var canvas_layer = get_node_or_null(canvas_layer_path)
@onready var offset: Vector2 = Vector2(offset_x, offset_y)
@onready var padding: Vector2 = Vector2(padding_x, padding_y)

func _ready() -> void:
	if(owner_node == null):
		owner_node = get_parent()
	
	# create the visuals
	_tooltip = tooltip_scene.instantiate()
	
	if(_tooltip.has_method("set_owner_node")):
		_tooltip.set_owner_node(owner_node)
	
	#add _tooltip to the ui canvas layer
	#	fallback to owner node if no canvas layer
	if(canvas_layer != null):
		canvas_layer.add_child(_tooltip)
	else:
		add_child(_tooltip)
	
	# connect signals
	owner_node.mouse_entered.connect(_on_mouse_entered_owner)
	owner_node.mouse_exited.connect(_on_mouse_exited_owner)
	_tooltip.mouse_entered.connect(_on_mouse_entered_tooltip)
	_tooltip.mouse_exited.connect(_on_mouse_exited_tooltip)
	
	# initialize the timer
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	
	# default to hide
	_tooltip.hide()
	
	if(_tooltip.has_signal("close_tooltip")):
		_tooltip.close_tooltip.connect(close_tooltip)

func _process(_delta: float) -> void:
	if(_force_close):
		close_tooltip()
	elif(_force_open):
		open_tooltip()
	elif(_mouseover_updated):
		if(_mouse_inside_owner || _mouse_inside_tooltip):
			if(!_timer.timeout.is_connected(open_tooltip)):
				_timer.timeout.connect(open_tooltip)
			if(_timer.timeout.is_connected(close_tooltip)):
				_timer.timeout.disconnect(close_tooltip)
			_timer.start(open_delay)
		else:
			if(!_timer.timeout.is_connected(close_tooltip)):
				_timer.timeout.connect(close_tooltip)
			if(_timer.timeout.is_connected(open_tooltip)):
				_timer.timeout.disconnect(open_tooltip)
			_timer.start(close_delay)
		_mouseover_updated = false
	
	if _tooltip.visible:
		_tooltip.set_position(calculate_tooltip_position())

func calculate_tooltip_position() -> Vector2:
	var border = (get_viewport().size as Vector2)
		
	#get owner position on screen
	var base_pos : Vector2
	if follow_mouse:
		base_pos = get_viewport().get_mouse_position()
	else:
		if owner_node is Node2D:
			base_pos = owner_node.get_screen_transform().origin
		elif owner_node is Control:
			base_pos = owner_node.get_screen_position()
	
	# get owner node size applicable for positioning ((0,0) if _tooltip follows mouse)
	var owner_size : Vector2
	if(follow_mouse):
		owner_size = Vector2.ZERO
	else:
		owner_size = owner_node.get_size()
	var _tooltip_size : Vector2 = _tooltip.get_size()
	
	var aligned_pos := base_pos
	#determine _tooltip position relative to owner position
	if(direction & Direction.RIGHT):
		#position _tooltip to the right of owner
		aligned_pos.x = base_pos.x + owner_size.x
	elif(direction & Direction.LEFT):
		#position _tooltip to the left of owner
		aligned_pos.x = base_pos.x - _tooltip_size.x
	else:
		if(alignment & Direction.LEFT):
			#align _tooltip with left edge of owner
			aligned_pos.x = base_pos.x
		elif(alignment & Direction.RIGHT):
			#align _tooltip with right edge of owner
			aligned_pos.x = base_pos.x - _tooltip_size.x + owner_size.x
		else:
			#center _tooltip horizontally with owner
			aligned_pos.x = base_pos.x + owner_size.x/2 - _tooltip_size.x/2
	
	if(direction & Direction.BOTTOM):
		#position _tooltip to the bottom of owner
		aligned_pos.y = base_pos.y + owner_size.y
	elif(direction & Direction.TOP):
		#position _tooltip to the top of owner
		aligned_pos.y = base_pos.y - _tooltip_size.y
	else:
		if(alignment & Direction.TOP):
			#align _tooltip with the top edge of owner
			aligned_pos.y = base_pos.y
		elif(alignment & Direction.BOTTOM):
			#align _tooltip with the bottom edge of owner
			aligned_pos.y = base_pos.y - _tooltip_size.y + owner_size.y
		else:
			#center _tooltip vertically with owner
			aligned_pos.y = base_pos.y + owner_size.y/2 - _tooltip_size.y/2
	
	#add specified offset
	aligned_pos = aligned_pos + offset
	
	var alt_offset = offset
	if(offset_relative):
		alt_offset = -offset
	
	#adjust horizontal to fit in viewport
	if(aligned_pos.x + _tooltip_size.x > border.x - padding.x):
		if(direction & Direction.TOP || direction & Direction.BOTTOM || direction == Direction.CENTER):
			#align with right side of viewport
			aligned_pos.x = border.x - _tooltip_size.x - padding.x
		else:
			#flip from right side of owner to left
			aligned_pos.x = base_pos.x - _tooltip_size.x + alt_offset.x
	elif(aligned_pos.x < padding.x):
		if(direction & Direction.TOP || direction & Direction.BOTTOM || direction == Direction.CENTER):
			#align with left side of viewport
			aligned_pos.x = padding.x
		else:
			#flip from left side of owner to right side
			aligned_pos.x = base_pos.x + owner_size.x + alt_offset.x
	
	#adjust vertical to fit in viewport
	if(aligned_pos.y + _tooltip_size.y > border.y - padding.y):
		if(direction & Direction.RIGHT || direction & Direction.LEFT || direction == Direction.CENTER):
			#align with bottom of viewport
			aligned_pos.y = border.y - _tooltip_size.y - padding.y
		else:
			#flip from bottom side of owner to top side
			aligned_pos.y = base_pos.y - _tooltip_size.y + alt_offset.y
	elif(aligned_pos.y < padding.y):
		if(direction & Direction.RIGHT || direction & Direction.LEFT || direction == Direction.CENTER):
			#align with top of viewport
			aligned_pos.y = padding.y
		else:
			#flip from top side of owner to bottom side
			aligned_pos.y = base_pos.y + owner_size.y + alt_offset.y
	
	return aligned_pos

func open_tooltip() -> void:
	if(_tooltip.has_method("_on_tooltip_open")):
		_tooltip._on_tooltip_open()
	_timer.stop()
	_tooltip.show()
	_mouseover_updated = false
	_force_open = false
	_force_close = false

func close_tooltip() -> void:
	if(_tooltip.has_method("_on_tooltip_close")):
		_tooltip._on_tooltip_close()
	_timer.stop()
	_tooltip.hide()
	_mouseover_updated = false
	_force_open = false
	_force_close = false

func _on_mouse_entered_owner() -> void:
	if(!_mouse_inside_owner):
		_mouse_inside_owner = true
		_mouseover_updated = true

func _on_mouse_exited_owner() -> void:
	if(_mouse_inside_owner):
		_mouse_inside_owner = false
		_mouseover_updated = true

func _on_mouse_entered_tooltip() -> void:
	if(!_mouse_inside_tooltip):
		_mouse_inside_tooltip = true
		_mouseover_updated = true

func _on_mouse_exited_tooltip() -> void:
	if(_mouse_inside_tooltip):
		_mouse_inside_tooltip = false
		_mouseover_updated = true
