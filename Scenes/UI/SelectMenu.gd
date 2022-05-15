extends Control
class_name SelectMenu

@export var button_scene : PackedScene

@export_node_path(Control) var buttons_container_path : NodePath
@onready var buttons_container : Control = get_node(buttons_container_path)

var buttons : Dictionary

enum MenuTypeEnum {OBJECTS, ACTIONS, ENHANCEMENT}
@export var menu_type: MenuTypeEnum = MenuTypeEnum.OBJECTS

func _ready():
	if(menu_type == MenuTypeEnum.OBJECTS):
		ObjectsManager.objects_status_updated.connect(_on_status_updated)
		ObjectsManager.selected_object_changed.connect(_on_selected_changed)
	elif(menu_type == MenuTypeEnum.ACTIONS):
		ActionManager.actions_status_updated.connect(_on_status_updated)
		ActionManager.selected_action_changed.connect(_on_selected_changed)
	elif(menu_type == MenuTypeEnum.ENHANCEMENT):
		EnhancementManager.enhancements_status_updated.connect(_on_status_updated)
		EnhancementManager.selected_enhancement_changed.connect(_on_selected_changed)
	
	reset()

# clear and rebuild menu contents
func reset():
	# clear all buttons
	for child in buttons_container.get_children():
		child.queue_free()
	buttons = {}
	
	# create buttons for all available keys
	for key in get_keys():
		var type : Dictionary = get_type(key)
		
		# create and insert button
		var button : Button
		if(button_scene == null):
			button = Button.new()
		else:
			button = button_scene.instantiate()
		button.text = str(type[Const.DISPLAY_NAME])
		button.pressed.connect(_on_button_pressed.bind(key))
		buttons_container.add_child(button)
		buttons[key] = button
	
	highlight_selected_button()

func get_keys() -> Array:
	if(menu_type == MenuTypeEnum.OBJECTS):
		return ObjectsManager.get_available_object_keys()
	elif(menu_type == MenuTypeEnum.ACTIONS):
		return ActionManager.get_available_action_keys()
	elif(menu_type == MenuTypeEnum.ENHANCEMENT):
		return EnhancementManager.get_available_enhancement_keys()
	else:
		return []

func get_type(key : String) -> Dictionary:
	if(menu_type == MenuTypeEnum.OBJECTS):
		return ObjectsManager.get_object_type(key)
	elif(menu_type == MenuTypeEnum.ACTIONS):
		return ActionManager.get_action_type(key)
	elif(menu_type == MenuTypeEnum.ENHANCEMENT):
		return EnhancementManager.get_enhancement_type(key)
	else:
		return {}

func get_selected_key() -> String:
	if(menu_type == MenuTypeEnum.OBJECTS):
		return ObjectsManager.get_selected_object_key()
	elif(menu_type == MenuTypeEnum.ACTIONS):
		return ActionManager.get_selected_action_key()
	elif(menu_type == MenuTypeEnum.ENHANCEMENT):
		return EnhancementManager.get_selected_enhancement_key()
	else:
		return ""

func highlight_selected_button():
	var selected_key : String = get_selected_key()
	if(buttons.has(selected_key)):
		buttons.get(selected_key).grab_focus()

func _on_button_pressed(key : String = ""):
	if(key == null || key == ""):
		return
	
	if(menu_type == MenuTypeEnum.OBJECTS):
		ObjectsManager.set_selected_object_key(key)
		ActionManager.set_selected_action_key("PURCHASE_PLOT_OBJECT")
	elif(menu_type == MenuTypeEnum.ACTIONS):
		ActionManager.set_selected_action_key(key)
	elif(menu_type == MenuTypeEnum.ENHANCEMENT):
		EnhancementManager.purchase_enhancement(key)
	else:
		return

# rebuild the menu content whenever overall status changes
func _on_status_updated():
	reset()

func _on_selected_changed():
	highlight_selected_button()
