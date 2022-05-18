extends PanelContainer
class_name TooltipPanel

signal close_tooltip()

@export_node_path(Button) var close_button_path : NodePath

@onready var close_button : Button = get_node_or_null(close_button_path)

var owner_node : Node

func _ready():
	if(close_button != null):
		close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	close_tooltip.emit()

func set_owner_node(_owner_node : Node):
	owner_node = _owner_node
