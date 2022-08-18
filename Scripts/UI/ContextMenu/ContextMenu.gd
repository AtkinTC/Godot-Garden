class_name ContextMenu
extends Node2D

var context_button_scene : PackedScene = preload("res://Scenes/UI/ContextMenu/ContextMenuButton.tscn")

@onready var menu_items_control : Control = %MenuItems
@onready var container : Control = %MarginContainer

var context_target_id : int = -1
var selection_hover_id : int = -1

var in_menu : bool = false

var actions : Array[Dictionary] = []
var buttons : Dictionary = {}

var select_duration : float = 1
var deselect_duration : float = 2

var select_time : float = 0
var deselect_time : float = 0

func _ready() -> void:
	set_visible(false)
	for child in menu_items_control.get_children():
		child.queue_free()
		
	SignalBus.node_selected.connect(_on_global_node_selected, CONNECT_DEFERRED)
	SignalBus.node_deselected.connect(_on_global_node_deselected, CONNECT_DEFERRED)
	SignalBus.node_mouse_entered.connect(_on_global_node_mouse_entered, CONNECT_DEFERRED)
	SignalBus.node_mouse_exited.connect(_on_global_node_mouse_exited, CONNECT_DEFERRED)
	
	container.mouse_entered.connect(_on_menu_mouse_entered, CONNECT_DEFERRED)
	container.mouse_exited.connect(_on_menu_mouse_exited, CONNECT_DEFERRED)

func _process(_delta) -> void:
	update_position()

func _physics_process(_delta: float) -> void:
	if(!in_menu):
		# check if target needs to be auto deselected
		if(context_target_id >= 0):
			if(selection_hover_id == -1 || selection_hover_id != context_target_id):
				if(deselect_time >= deselect_duration):
					SignalBus.node_deselected.emit(context_target_id)
					deselect_time = 0
				else:
					deselect_time += _delta
		
		# check if target needs to be auto selected
		if(selection_hover_id >= 0 && selection_hover_id != context_target_id):
			if(select_time >= select_duration):
				SignalBus.node_selected.emit(selection_hover_id)
				select_time = 0
			else:
				select_time += _delta

# update the menu position based on the target node position the camera transform
func update_position() -> void:
	if(context_target_id < 0):
		position = Vector2.ZERO
		update()
		return
	
	var target : Node = instance_from_id(context_target_id)
	if(target == null):
		position = Vector2.ZERO
		update()
		return
	
	var target_pos : Vector2 = target.get_global_position()
	var game_world : World = ResourceRef.get_current_game_world()
	if(game_world):
		target_pos = game_world.world_to_screen(target_pos)
	position = target_pos
	update()

# get the list of context actions for the current target
func retrieve_context_actions() -> Array[Dictionary]:
	if(context_target_id < 0):
		return []
	
	var target : Node = instance_from_id(context_target_id)
	if(target == null || !target.has_method("get_context_actions")):
		return []
	
	return target.get_context_actions() as Array[Dictionary]

# update the contents of the menu
func update_menu_items_display() -> void:
	var new_actions : Array[Dictionary] = retrieve_context_actions()
	
	var updated := false
	
	if(new_actions.size() != actions.size()):
		updated = true
	else:
		for i in range(new_actions.size()):
			if(new_actions[i].key != actions[i].key):
				updated = true
				break
	
	if(!updated):
		return
	
	actions = new_actions
	# remove all buttons
	for button in buttons.values():
		button.queue_free()
	buttons = {}
	
	if(new_actions.size() > 0):
		# add all button
		for action in actions:
			var new_button : ContextMenuButton = context_button_scene.instantiate()
			new_button.set_text(action.display_name)
			new_button.pressed.connect(func(): SignalBus.node_deselected.emit(-1); action.callback.call())
			buttons[action.key] = (new_button)
			menu_items_control.add_child(new_button)
	update()

func _on_global_node_selected(inst_id : int) -> void:
	if(inst_id != context_target_id):
		select_time = 0
		deselect_time = 0
		context_target_id = inst_id

		update_position()
		update_menu_items_display()
		in_menu = false
		
		if(context_target_id >= 0):
			set_visible(true)

func _on_global_node_deselected(inst_id : int) -> void:
	if(inst_id == context_target_id || inst_id == -1):
		deselect_time = 0
		context_target_id = -1
		position = Vector2.ZERO
		update_menu_items_display()
		in_menu = false
		set_visible(false)

func _on_global_node_mouse_entered(inst_id : int) -> void:
	if(inst_id != selection_hover_id):
		selection_hover_id = inst_id
		select_time = 0
	else:
		deselect_time = 0

func _on_global_node_mouse_exited(inst_id : int) -> void:
	if(inst_id == selection_hover_id):
		selection_hover_id = -1
		select_time = 0
		deselect_time = 0
		
func _on_menu_mouse_entered() -> void:
	in_menu = true
	select_time = 0
	deselect_time = 0

func _on_menu_mouse_exited() -> void:
	in_menu = false
	select_time = 0
	deselect_time = 0
