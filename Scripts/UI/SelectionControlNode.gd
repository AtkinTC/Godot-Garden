# SelectionControlNode marks a selectable game object
# Monitors mouse_entered, mouse_exited and input_events and sends those signals to the global SignalBus

class_name SelectionControlNode
extends Area2D

var mouse_hovering : bool = false
var selected : bool = false

@onready var shape : Shape2D = get_node("CollisionShape2D").get_shape()

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	SignalBus.node_selected.connect(_on_global_node_selected)
	SignalBus.node_deselected.connect(_on_global_node_deselected)

func set_selected(_selected : bool) -> void:
	if(_selected == selected):
		return
	selected = _selected
	update()

# returns the list of context actions that will be used to create this node's context manu
func get_context_actions() -> Array[ActionDefinition]:
	var actions : Array[ActionDefinition] = []
	
	var action := ActionDefinition.new()
	action.key = "test1"
	action.display_name = "test 1"
	action.callback = callback_test_1
	actions.append(action)
	
	action = ActionDefinition.new()
	action.key = "test2"
	action.display_name = "test 2"
	action.callback = callback_test_2
	actions.append(action)
	
	return actions

func callback_test_1():
	print("callback_test_1")

func callback_test_2():
	print("callback_test_2")

func _on_mouse_entered() -> void:
	mouse_hovering = true
	SignalBus.node_mouse_entered.emit(get_instance_id())
	update()

func _on_mouse_exited() -> void:
	mouse_hovering = false
	SignalBus.node_mouse_exited.emit(get_instance_id())
	update()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if(event.is_action_pressed("mouse_left")):
		SignalBus.node_selected.emit(get_instance_id())

func _on_global_node_selected(inst_id : int) -> void:
	if(inst_id == get_instance_id()):
		set_selected(true)
	if(inst_id != get_instance_id()):
		set_selected(false)

func _on_global_node_deselected(inst_id : int) -> void:
	if(inst_id == get_instance_id() || inst_id == -1):
		set_selected(false)

func _draw():
	if(!mouse_hovering && !selected):
		return
	
	if(shape is CircleShape2D):
		if(selected):
			draw_arc(Vector2.ZERO, shape.get_radius()-2, 0, TAU, 16, Color.RED, 2)
		if(mouse_hovering):
			draw_arc(Vector2.ZERO, shape.get_radius(), 0, TAU, 16, Color.BLUE)
