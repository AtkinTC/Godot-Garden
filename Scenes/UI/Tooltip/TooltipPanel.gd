extends PanelContainer
class_name TooltipPanel

signal close_tooltip()

@export_node_path(Button) var close_button_path : NodePath

@onready var close_button : Button = get_node(close_button_path)

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	close_tooltip.emit()
